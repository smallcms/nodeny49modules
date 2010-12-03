#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (�) Volik Stanislav, 2008, 2009
# Copyright (�) Dmitry Belov, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub RMTR_main
{


 &Error($V ? '������ �� ��������������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) if !$RMTR_price && !$RMTR_mnbap && !$RMTR_minsrc && !$RMTR_minsrc && !$RMTR_maxsrc && !$RMTR_maxdst && !$RMTR_ntrvlsrc && !$RMTR_ntrvldst && !$RMTR_dopid && !$RMTR_overdebt && !$RMTR_oldpay;
 &Error($V ? '������ �������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) if !$RMTR_enable;

 $RMTR_post1= $F{rmtrpk};
 $RMTR_post2= $F{rmtray};
 
 $FormText = '������ "���������� ��������" ��������� �������� ����� ������� � ������ ����� �� ������ ����.'.
             '' . $br2 .
             &bold('������� ������������ �������� ��� ���������� : ').
             &input_t('rmtrpk',$RMTR_post1,10,8,' autocomplete="off"').$br2.
             &bold('������� �����, ������� ������� ��������� ���������� (' .($RMTR_minsrc+$RMTR_price).'...'.($RMTR_maxsrc+$RMTR_price).' '.$gr.'): ').
             &input_t('rmtray',$RMTR_post2,20,18,' autocomplete="off"');
 #������� �������� ��� ��� ���-���� ������� ������!
 $FormText .= $br2.'������������� �� ������������� ������ � ������� �� ������� ���������� ����� ������� ����� � ������� '.&bold($RMTR_price.' '.$gr) if $RMTR_price > 0;

 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('���������� ��������')
   )
 );

 #��������, ��������� �� ������������ ������������ ������?
 $RMTR_DenyToUseMod = 0; # �������� ��-���������.
 $RMTR_sql0=&sql_select_line($dbh,"SELECT field_value FROM dopdata WHERE parent_id=".$id." AND dopfield_id=".$RMTR_dopid." AND revision=(SELECT MAX(revision) from dopdata WHERE parent_id=".$id." AND dopfield_id=".$RMTR_dopid.")");
 if($RMTR_sql0) # ��� ��� �� ������������� �������� ����� ����������. ���� ���.�������� ������� �� ����������� - �� ������� 0. ���� ����������� - �� ������� �� 0 :)
 {
 	$RMTR_DenyToUseMod=$RMTR_sql0->{'field_value'}; # ��������� ��� ��������� �� ����. ��������, ����� ��������� ������. (����������� � 1)	
 } 
 &Error('�� �� ������ ��������������� ������ �������. ���������� � ���������� ��������������') if $RMTR_DenyToUseMod == 1;

 #�������� ���������� ������������� ������ �� ��������� RMTR_ntrvlsrc ����
 $RMTR_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =10 AND `category` =105 AND `reason` = '�� ������ ���������� ��������' AND `coment` ='�� ������ ���������� ��������' AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_ntrvlsrc ) )");
 &Error('�������� � ��.') unless $RMTR_sql1;
 #������� ���������� ������������� ������
 $RMTR_count1=$RMTR_sql1->{'COUNT(*)'};
 #������� ��������� ������������
 &Error('�� ��� ������������ ������ &quot;���������� ��������&quot; �����, ��� ' . $RMTR_ntrvlsrc . ' ' .&PP_days($RMTR_ntrvlsrc). ' �����.') if $RMTR_count1 > 0 && $RMTR_ntrvlsrc != 0;


 #���� �� �������� ������� �� ������ �����
 unless (defined $F{rmtray} && defined $F{rmtrpk})
   {
    #���������� ����� ����� �������
    $OUT.=&MessX($form,1);
    return;
   }


 #�������� �� ����� ��������
 &Error('�� ����� ������������ ���������� �������� � ���� ����������.',$EOUT) if length($RMTR_post1)<2 || length($RMTR_post1)>10;
 &Error('�� ����� ������������ ���������� �������� � ����� ��������.',$EOUT) if length($RMTR_post2)<1 || length($RMTR_post2)>20;
 #�������� �� ������������ (�������� ������ � �������)
 &Error('������������ ������������ �������.',$EOUT) if $RMTR_post1!~/^[0-9]+$/;
 &Error('������������ ������������ �������.',$EOUT) if $RMTR_post2!~/^[0-9]+$/;

 #�������� �� ���������� ������� ����� ��������
 &Error('��� ������ ����� �������� ����� ���������� �� ������ ���� ������ '.$RMTR_mnbap.' '.$gr,$EOUT) if $U{$Mid}{balance}-$RMTR_post2 < $RMTR_mnbap && $RMTR_mnbap !=0;
 #�������� �� ����������� �����
 &Error('����� �������� ������� ������ ���������� ����������.',$EOUT) if $RMTR_post2 < $RMTR_minsrc+$RMTR_price && $RMTR_minsrc != 0;
 #�������� �� ������������ �����
 &Error('����� �������� ������� ������ ����������� ���������� (' . ($RMTR_maxsrc+$RMTR_price) . ').',$EOUT) if $RMTR_post2 > $RMTR_maxsrc+$RMTR_price && $RMTR_maxsrc != 0;

 #���� ������� ������ �� ������������� ���������� ����
 $RMTR_post1id=substr($RMTR_post1,0,-1);

 #�������� ������� ������ �� ������������� ���������� ����
 $RMTR_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM `users` WHERE `id`=$RMTR_post1id AND `mid`=0");
 &Error('�������� � ��.') unless $RMTR_sql1;
 #������� ���� �� ����
 $RMTR_count1=$RMTR_sql1->{'COUNT(*)'};
 #������� ��������� ������������, ��� ������ ���������� ���� �� ���������
 &Error('�� ������� �������������� ������������ ��������� ��� ����������.') if $RMTR_count1 != 1;

 #�������� ����� ��������-��������� ������� ������ �� ������������� ���������� ����
 $RMTR_sql2=&sql_select_line($dbh,"SELECT SUM(`cash`) AS `cash` FROM `pays` WHERE `mid`=$RMTR_post1id AND `type` =10 AND `category` =600 AND `reason` = '�� ������ ���������� ��������' AND `coment` ='�� ������ ���������� ��������' AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_ntrvldst ) )");
 &Error('�������� � ��.') unless $RMTR_sql2;
 #�������� �������� �����
 $RMTR_maxdst_sql=$RMTR_sql2->{cash};
 #������� ��������� ������������, ��� ���������� ��� ����� ������� �������
 &Error('�� ������� ���������� ��� ������� ����������� ��������� �����.') if $RMTR_maxdst_sql >= $RMTR_maxdst && $RMTR_maxdst !=0;

 #�������� �������� ������� ������� ������ �� ������������� ���������� ���� (����� ����������� ���������)
 $RMTR_sql3=&sql_select_line($dbh,"SELECT COUNT(*) FROM `pays` WHERE `mid`=$RMTR_post1id AND `cash`>0 AND `type` ='10' AND `category` ='600' AND `reason` !='�� ������ ���������� ��������' AND `coment` !='�� ������ ���������� ��������' AND `time`>UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_oldpay))");
 &Error('�������� � ��.') unless $RMTR_sql3;
 #�������� �������� �����
 $RMTR_oldpay_sql=$RMTR_sql3->{'COUNT(*)'};
 #������� ��������� ������������, ��� ���������� ����� ����� �� ��������
 &Error('���������� ����� ����� �� �������� ���� ����.') if $RMTR_oldpay_sql < 1 && $RMTR_oldpay !=0;

 #�������� ������ ������� ������ �� ������������� ���������� ����
 $RMTR_sql4=&sql_select_line($dbh,"SELECT `balance` FROM `users` WHERE `id`=$RMTR_post1id AND `mid` =0");
 &Error('�������� � ��.') unless $RMTR_sql4;
 #�������� �������� �����
 $RMTR_overdebt_sql=$RMTR_sql4->{balance};
 #������� ��������� ������������, ��� ���������� ���� � ������� �����
 &Error('�� ����� ���������� ������� ������� �������������.') if $RMTR_overdebt_sql <= $RMTR_overdebt && $RMTR_overdebt !=0;

 #�������� ���� ������ ����� �������� ����� ������ ���� - ������� ��������� ������������
 &Error('�� ������� ����� ������, ��� � ��� ���� �� �����.') if ($U{$Mid}{final_balance} - $RMTR_post2) < 0;

 #�� ���������

 #��������� ����� � ������� RMTR_post2 �� ������ ���������� ��������
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,-$RMTR_post2,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'�� ������ ���������� ��������','�� ������ ���������� ��������',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ���������� �������� (������ ��������) $RMTR_post2 $gr ��� ��� $RMTR_post1, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� ����������� �������� � ������� �������� (��������)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance-".$RMTR_post2." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid ����������� ������ ���������� �������� $RMTR_post2 $gr ��� ��� $RMTR_post1, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
    &Error("��������� ������ �������� �����. ���������� � �������������.",$EOUT);
   }

 #�������� �� ����� �������� ��������� ������
 $RMTR_post2_tmp = $RMTR_post2 - $RMTR_price;

 #���� ������� ��������� ����� �� ������
 if ($RMTR_price > 0)
   {
     #��������� ����� � ������� RMTR_price �� ������ ���������� ��������
     $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
         "VALUES($RMTR_post1id,-$RMTR_price,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'�� ������ ���������� ��������','�� ������ ���������� ��������',$t)";

     $rows=&sql_do($dbh,$sql);
     &ToLog("! mid $Mid ����������� ������ ���������� �������� (������ ���������) $RMTR_price $gr ��� ��� $RMTR_post1, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;
   }

 #��������� ����� � ������� RMTR_post2-RMTR_price �� ������ ���������� �������� ������� � id=$RMTR_post1id
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($RMTR_post1id,$RMTR_post2,10,'',600,$Adm{id},INET_ATON('$RealIp'),'�� ������ ���������� ��������','�� ������ ���������� ��������',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ���������� �������� (������ ����������) $RMTR_post2 $gr ��� ��� $RMTR_post1, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� ����������� �������� � ������� �������� (����������)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$RMTR_post2_tmp." WHERE id=$RMTR_post1id LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid ����������� ������ ���������� �������� $RMTR_post2_tmp $gr ��� ��� $RMTR_post1, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
    &Error("��������� ������ �������� �����. ���������� � �������������.",$EOUT);
   }
 
 # �������� ������ ����������, ���� ����� ������������ - ��� ����� ��������
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$RMTR_post1id OR mid=$RMTR_post1id");
 
 #�������� �������, ��� �� ���������
 &OkMess(&bold_br("���� � ������������ �������� ����� $RMTR_post1 �������� �� $RMTR_post2_tmp $gr").'���� ������� ������� ���������� ��� ��������� ������� � �������� - ������ ���������� ����� ������� � ������� ���������� �����.'.$br2);


}

#������������ ��� ������ ��������� �������� ����
sub PP_days {
	$days_10 = $_[0] % 10;
 	if($days_10 == 1) { return '����'; }
 	elsif($days_10 > 1 && $days_10 < 5) { return '���'; }
 	else { return '����'; }
}

1;
