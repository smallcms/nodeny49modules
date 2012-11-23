#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (�) Volik Stanislav, 2008, 2009
# Read license http://nodeny.com.ua/license.txt
# ---------------------------------------------
# ������ (ipn) ������ �������� �������� PayPal
# Copyright (�) Dzmitry Bialou, 2011
# --------------------------------------------- 

require "PayPal.pm";

$Max_byte_upload = 1024 * 100; # Limit post to 100kB

&GetFields();

#print "Content-type: text/html\n\n";
#while ( my ($key, $value) = each(%query) ) {
#            print "$key => $value <br />\r\n";
#	        }

my $id = $query{custom};
my $paypal = Business::PayPal->new($id);
my ($txnstatus, $reason) = $paypal->ipnvalidate(\%query);
die "PayPal failed: $reason" unless $txnstatus;
my $paystatus = $query{payment_status};
my $receiver_email = $query{receiver_email};


if ($reason =~ /VERIFIED/ && $paystatus =~ /Completed/) {

use DBI;

$Main_config='/usr/local/nodeny/nodeny.cfg.pl';
eval{ &get_main_config() };

(-e $Main_config) or die('error :(');
eval{require $Main_config};

$Nodeny_dir_web="$Nodeny_dir/web";

$call_pl="$Nodeny_dir_web/calls.pl";
(-e $call_pl) or die('error :(');
require $call_pl;

#���� �� ��������������� � �� ������� - �� ��������
die('no config!') unless $PLPL_enabled && $PLPL_account && $PLPL_currency && $PLPL_ipn_url && $PLPL_cipher;
die('not enabled!') unless $PLPL_enabled;

# �������� � IPN ��������, ����� �������� http-������ 200
print "Content-type: text/html\n\n";
#print "content-type: text/plain\n\n";

#print "<strong>VERIFIED!</strong><br />\n\n";

$ut='unix_timestamp()';
$DSN="DBI:mysql:database=$db_name;host=$db_server;mysql_connect_timeout=$db_conn_timeout;";
$dbh=DBI->connect($DSN,$user,$pw,{PrintError=>1});
$dbh or die('error :(');
&SetCharSet($dbh);

$p=&sql_select_line($dbh,"SELECT $ut");
$p or die('error :(');
$t=$p->{$ut};

#print "$t<br />\n";

#print 'status='.$paystatus."<br />\n\n";
#print 'id='.$id."<br />\n\n";
#print 're='.$reason."<br />\n\n";
#print 'receiver_email='.$receiver_email."<br />\n\n";

$PLPL_cipher=sprintf("%.32s",sprintf("% 32s", $PLPL_cipher));

die('error :(') if $receiver_email != $PLPL_account;

# ������������� ���������� ������ (���������� �������, ���������� ������, �����)
($PLPL_Mid,$PLPL_ses,$PLPL_money) = &PLPL_AES_DECRYPT($id);
#print "DECRYPT=$PLPL_Mid $PLPL_ses $PLPL_money<br />\n\n";

# ��������: ������� �� ����� ����� (�������� ����� ������ ipn.pl ��� web-����������)
$PLPL_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$PLPL_Mid AND `type` =10 AND `category` =8 AND `reason` ='$PLPL_ses'");
print('error in DB') unless $PLPL_sql1;
$PLPL_sql_count1=$PLPL_sql1->{'COUNT(*)'};

# �����������. �������!
#print "COUNT:$PLPL_sql_count1";

# ���� ������ ��� �� ��������
if ($PLPL_sql_count1 == 0)
 {
  $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
       "VALUES($PLPL_Mid,$PLPL_money,10,'y',8,0,0,'$PLPL_ses','������ ����� ������� PayPal (�������������� IPN)',$t)";
  $rows=&sql_do($dbh,$sql);
  &ToLog("! ������ PayPal-IPN ����������� ������ PayPal (������ ����������) $PLPL_money $gr ��� id $PLPL_Mid, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;
  
  #�������� ����������� �������� � ������� �������� (����������)
  $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$PLPL_money." WHERE id=$PLPL_Mid LIMIT 1");
  if ($rows<1)
    {
     &ToLog("! ������ PayPal-IPN ����������� ������ PayPal $PLPL_money $gr ��� id $PLPL_Mid, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
     }
  # �������� ������ ����������, ���� ����� ������������ - ��� ����� ��������
  &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$PLPL_Mid OR mid=$PLPL_Mid");               
 }


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


# ������� ��������� ���������� �� GET � POST
sub GetFields
{

if( $ENV{REQUEST_METHOD} eq 'POST' )
{
   $t=$ENV{CONTENT_LENGTH};
   $t>$Max_byte_upload && &Error_X("����� ���������� post-������� ������ �������� $Max_byte_upload ����",'����� ���������� ������ �������� ���������� ��������.'); 
   read(STDIN,$p,$t)
}else
{
   $p='';
}

$p.='&'.$ENV{QUERY_STRING};

%query=();   
foreach( split /&/,$p )
{
   ($name,$value)=split /=/;
   $name=~tr/+/ /;
   $name=~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
   $value=~tr/+/ /;
   $value=~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
   $query{$name}=$value;
}

}

