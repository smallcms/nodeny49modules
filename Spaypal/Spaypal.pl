#!/usr/bin/perl
# ------------------- NoDeny ------------------
# ������ ������ �������� �������� PayPal
# Copyright (�) Dzmitry Bialou, 2011
# --------------------------------------------- 
#$VER=49.32;

use Digest::MD5 qw(md5_hex);

sub PL_main
{
 &Error($V ? '������ �� ��������������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) unless $PLPL_enabled && $PLPL_account && $PLPL_currency && $PLPL_ipn_url && $PLPL_cipher;
 &Error($V ? '������ �������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) unless $PLPL_enabled;
 # �������� �������� ��� PayPal
 $PLPL_prodname=$Title_net;
 # �������� ����� ��� AES ���������� ��� 32 �������
 $PLPL_cipher=sprintf("%.32s",sprintf("% 32s", $PLPL_cipher));
 # ��������� ����� ��������� ������
 $PLPL_new_session=md5_hex(rand());

 # ���������� �� ������� PayPal
 if ($PLPL_show_logo) {
   $OUT.='<img src="'.$img_dir.'/paypal/PayPal_logo_150x65.gif" alt="">';
   }

 $PLPL_ppamount=$F{ppamount};
 $form=&div('cntr',
   &form('!'=>1,
     (
      &bold('������� ����� ���������� �����: ').&input_t('ppamount',$PLPL_ppamount,8,7,' autocomplete="off"').' '.$PLPL_currency.
      &input_h('ppsession',$PLPL_new_session)
     ).$br2.&submit_a('���������')
   )
 );

# ���������� ���������� paypal, ������� ����� ��������� ������ ��� ���������� �����
 if (defined $F{paypal})
   {
    if ($F{paypal} == "1")
    {
    # ������������ ����� ��������� �� PayPal � �������
    # ������������ ������ .pm
    use lib "/usr/local/www/apache22/paypal";
    use Business::PayPal;
    my %query = %F;

    # ���������� �������� ���������� ��������� ����� ������
    # PayPal ��� �������� ������ ������� VERIFIED
    my $papid = $query{custom};
    my $paypal = Business::PayPal->new($papid);
    my ($txnstatus, $reason) = $paypal->ipnvalidate(\%query);
    # ���-�� �� ��� � �������, ��������� ����� ��� ��������
    &ToLog("! mid $Mid ����������� ������ PayPal. ���������� �� �������������!") unless $txnstatus;
    &Error($V ? "PayPal failed: $reason" : "������� ������. ���� ������ ���������� �������������.") unless $txnstatus;
    # �������������� ��������, ��� ������� PayPal ��������� ��� VERIFIED, ����� ��� ��������
    if ($reason =~ /VERIFIED/ && $query{payment_status} =~ /Completed/)
      {
      #�������� ���������� ������� � PayPal
      &ToLog("! mid $Mid ����������� ������ PayPal. ���������� �� �������������!") if $receiver_email != $PLPL_account;
      &Error($V ? "PayPal IPN failed" : "������� ������. ���� ������ ���������� �������������.") if $receiver_email != $PLPL_account;
      # ������������� ���������� ������ (���������� �������, ���������� ������, �����)
      ($PLPL_Mid,$PLPL_ses,$PLPL_money) = &PLPL_AES_DECRYPT($query{custom});

      # ��������: ������� �� ����� ����� (�������� ����� ������ ipn.pl)
      $PLPL_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$PLPL_Mid AND `type` =10 AND `category` =8 AND `reason` ='$PLPL_ses'");
      &Error('�������� � ��.') unless $PLPL_sql1;
      $PLPL_sql_count1=$PLPL_sql1->{'COUNT(*)'};
      # ���� ������ ��� ��������
      if ($PLPL_sql_count1 != 0)
      {
       # �� �������� ������������, ��� ������� ��� ���� ����������� ����� ipn � �� ����� ��� ��������
       # ������ ����� - ������ �������� ��������
       &OkMess(&bold_br('������ ���� ������� ��������.').'���� ������� ������� ���������� ��� ��������� ������� � �������� - ������ ����� ������� � ������� ���������� �����.');
       &Exit;
      } else {
               #������� �� ������� PayPal->ipn �� ���������. ������ ������ ����� ������
               $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
                    "VALUES($PLPL_Mid,$PLPL_money,10,'y',8,$Adm{id},INET_ATON('$RealIp'),'$PLPL_ses','������ ����� ������� PayPal',$t)";
               $rows=&sql_do($dbh,$sql);
               &ToLog("! mid $Mid ����������� ������ PayPal (������ ����������) $PLPL_money $gr ��� id $PLPL_Mid, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

               #�������� ����������� �������� � ������� �������� (����������)
               $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$PLPL_money." WHERE id=$PLPL_Mid LIMIT 1");
               if ($rows<1)
                 {
                   &ToLog("! mid $Mid ����������� ������ PayPal $PLPL_money $gr ��� id $PLPL_Mid, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
                   &Error("��������� ������ ���������� �����. ���������� � �������������.",$EOUT);
                 }
               # �������� ������ ����������, ���� ����� ������������ - ��� ����� ��������
               &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$PLPL_Mid OR mid=$PLPL_Mid");               

               &OkMess(&bold_br('������ ���� ������� ��������.').'���� ������� ������� ���������� ��� ��������� ������� � �������� - ������ ����� ������� � ������� ���������� �����.');
               &Exit;
              }

      } else {
       &ToLog("! mid $Mid ����������� ������ PayPal. ���������� �� �������������!");
       &Error($V ? "PayPal IPN failed" : "������� ������. ���� ������ ���������� �������������.");
      }

    return;
    }
    elsif ($F{paypal} == "2")
      {
      # ������������ ����� � PayPal ������ �������, ��������� ������������ �� ����
      &PLPL_cancel;
      }
   }
 
 unless (defined $F{ppamount} && $F{ppsession})
   {
    $OUT.=&MessX($form,1);
    return;
   } 

$PLPL_session=$F{ppsession};

 # �������� ������������ ����� �����
 # �������� �� ����� ��������
 &Error('�� ����� ������������ ���������� �������� � ����� ���������� �������.',$EOUT) if length($PLPL_ppamount)<1 || length($PLPL_ppamount)>20;
 &Error('������ ������.',$EOUT) if length($PLPL_session) != 32;
 # ���������� ������� �� ����� (������ ���� ����� �������)
 $PLPL_ppamount=~s/,/./;
 &Error('������������ ������������ �������.',$EOUT) if $PLPL_ppamount!~/^[0-9.]+$/;


 # �������������� ������������ � ����� �������� � PayPal
 $paypalform2='';
 $paypalform2.=&bold_br('��� ������ ����� ����������� �������������� ��������� �����!');
 # �������������� ���� � ������������ � ������������ PayPal (X.XX)
 $PLPL_ppamount=sprintf("%.2f",$PLPL_ppamount*1);
 $paypalform2.=&bold($PLPL_ppamount.' '.$PLPL_currency);
 # ���� �� ����� �������������� - ������ PayPal=������ NoDeny
 if (!$PLPL_currency_billing) {
   $PLPL_currency_billing_amount=$PLPL_ppamount;
   $paypalform2.=&bold(' ����� ��������� �� ��� ����');
   } else {
     # ����� ������ �������������� �������� &PLPL_Conv_paypal_to_local
     $paypalform2.=&bold(' ����� �������������� � ������ ����������� �������: ');
     $PLPL_currency_billing_amount=&PLPL_Conv_paypal_to_local($PLPL_currency,$PLPL_currency_billing,$PLPL_ppamount);
     # ���� ������ �� ��������� (�������� ���������� ���� ���������), ��������� ������, ������������ ������
     &Error($V ? "������ ��������� ������ �� ���������� �����." : "������ ��������� �����. ������ �������� ����������.") if (!$PLPL_currency_billing_amount);
     $paypalform2.=&bold($PLPL_currency_billing_amount.' '.$PLPL_currency_billing);
     $paypalform2.=&bold(' � ����� ��������� �� ��� ����');
     }
 # ���������� ���������� id ������������, ���������� ������ � ����� ������� (��� ����������������� �� �����)
 $PLPL_custom_value = &PLPL_AES_ENCRYPT($Mid,$PLPL_session,$PLPL_currency_billing_amount);

 $paypalform2.=$br2;
 # ����������� ���������� url ��� �������� � PayPal
 if ($ENV{HTTPS} && $ENV{HTTPS} == "on") {$paypalform2_proto='https://';} else {$paypalform2_proto='http://';}
 $paypalform2.='
 <form method="post" action="https://www.paypal.com/cgi-bin/webscr" enctype="multipart/form-data" onsubmit="javascript:document.getElementById(\'divPayPal\').innerHTML=\'<div class=message>������ �������. �����...</div>\';">
   <input type="hidden" name="redirect_cmd" value="_xclick" />
   <input type="hidden" name="business" value="'.$PLPL_account.'"  />
   <input type="hidden" name="currency_code" value="'.$PLPL_currency.'" />
   <input type="hidden" name="cmd" value="_ext-enter" />
   <input type="hidden" name="no_shipping" value="1" />
   <input type="hidden" name="custom" value="'.$PLPL_custom_value.'" />
   <input type="hidden" name="no_note" value="1" />
   <input type="hidden" name="quantity" value="1" />
   <input type="hidden" name="return" value="'.$paypalform2_proto.$ENV{HTTP_HOST}.$scrpt.'&paypal=1" />
   <input type="hidden" name="cancel_return" value="'.$paypalform2_proto.$ENV{HTTP_HOST}.$scrpt.'&paypal=2" />
   <input type="hidden" name="notify_url" value="'.$paypalform2_proto.$ENV{HTTP_HOST}.$PLPL_ipn_url.'" />
   <input type="hidden" name="item_name" value="'.$PLPL_prodname.'" />
   <input type="hidden" name="undefined_quantity" value="0" />
   <input type="hidden" name="amount" value="'.$PLPL_ppamount.'" />
   <div id=divPayPal class=cntr>
   <input type="submit" name="submit" value="� ���������� � ���������, ���������� ������" />
   </div>
 </form>
 ';
 &Message_Exit($paypalform2);
}

# FEATURE! (����, �������)
# ������������ ����������� ������ � ���������� �����
# �������: ���������� ������
#sub PLPL_currency_in_list
#{
# my $currency="<select size=1 name=currency>";
# $currency.="<option value=EUR>EUR</option>";
# $currency.="<option value=USD>USD</option>"; 
# $currency.="</select>";
# return $currency;
#}

# ������� ��������� ����������������� �����
# �����: &PLPL_Conv_paypal_to_local(������_PayPal,������_��������,�����)
# �������: ����������������� ������
sub PLPL_Conv_paypal_to_local
{
# ���������� ��� ����������: �����, ����, ����
# exchange-rates.org ���� ��� �������� �������,
# �� ����� ���������� ����� �����
my $host = "www.exchange-rates.org";
#my $host = "localhost"; #fake_test_1
#my $host = "google.com";     #fake_test_2
my $port = "80";
#my $uri = "/test.html"; #uri_fake_test
my $uri = "/converter/$_[0]/$_[1]/";

# ��������� ������ �������
my $socket = IO::Socket::INET->new("$host:$port");
# ����� �� ����� ������, ����� ������� ��������� ������� ������
unless ($socket) {&Error($V ? "can't connect to HTTP server on $host:$port: $!" : '������ ��������� �����. ������ �������� ����������.',$EOUT);}
$socket->autoflush(1);
# ������������ ����� ������ � �������� ������
print $socket "GET $uri HTTP/1.1\nHost: $host\nUser-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\nAccept: text/html\nConnection: close\nReferer: http://www.exchange-rates.org/converter.aspx\n\n";
my $answer;
# ������ �������� � ���������� � ����� ������ ������
while (<$socket>) {$answer.="$_";}
close $socket;

# ��������� ������ ���, �������� ����������������� �������� ������
if ($answer =~ m/<span id=\"ctl00_M_lblToAmount\">([\d,.]+)<\/span>/)
  {
  my $curval = $1;
  $curval =~ s/,//;
  # �������������� ����� �� �����, ��������� �� ���������� PayPal-������
  my $curval=sprintf("%.2f",$curval*$_[2]);
  #
  return $curval;
  }
}

# ������� ����������� ������������ ������
# �����: &PLPL_AES_data(Mid_������������, ����������_������_������, �����������������_�����_����������)
# ������� e: ���, ������, ����� ������������� AES � �������������� � base64 (������ ������)
sub PLPL_AES_ENCRYPT
{
 use Crypt::Rijndael;
 use MIME::Base64;
 # ��������� ���
 my $csum=0;
 $csum+=$_ foreach split //,$_[0];
 $csum%=10;
 my $ppk="$_[0]$csum";
 # ���������� � ���������� ���, ������, �����
 my $crypt_ppk=sprintf("% 32s", $ppk);
 my $crypt_ses=$_[1];
 my $crypt_sum=sprintf("% 32s", $_[2]);
 my $cipher = new Crypt::Rijndael $PLPL_cipher, Crypt::Rijndael::MODE_CBC;
 # ��������� ������ � AES
 my $crypt_ppk = $cipher->encrypt($crypt_ppk);
 my $crypt_ses = $cipher->encrypt($crypt_ses);
 my $crypt_sum = $cipher->encrypt($crypt_sum);

 # ������������� ������ ����������� � base64, ��������� ����� ������� - ����������� �� '\n'
 my $crypt_all = encode_base64($crypt_ppk.'___EOT'.$crypt_ses.'___EOT'.$crypt_sum, '');

 return $crypt_all;
}

# ������� ������������� ������������ ������
# �����: &PLPL_AES_DECRYPT(������_��������������_�_base64)
# �������: �������������� Mid, ������, ����� (��� ��������)
sub PLPL_AES_DECRYPT
{
 use Crypt::Rijndael;
 use MIME::Base64;
 $decrypt = decode_base64($_[0]);
 my ($decrypt_ppk, $decrypt_ses, $decrypt_sum) = split (/___EOT/,$decrypt);
 my $cipher = new Crypt::Rijndael $PLPL_cipher, Crypt::Rijndael::MODE_CBC;
 my $decrypt_ppk = &trim($cipher->decrypt($decrypt_ppk));
 my $decrypt_ses = $cipher->decrypt($decrypt_ses);
 my $decrypt_sum = &trim($cipher->decrypt($decrypt_sum));
 my $decrypt_mid = substr($decrypt_ppk,0,-1);
 return $decrypt_mid,$decrypt_ses,$decrypt_sum;
}

sub PLPL_cancel
{
# ������������ ����� � PayPal ������ �������, ��������� ������������ �� ����
 $OUT.=&Error('������ ��������. ����� �� ���� �����������.');
 return;
}

1;

