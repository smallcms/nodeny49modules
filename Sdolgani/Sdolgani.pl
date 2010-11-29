#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (�) Volik Stanislav, 2008, 2009
# Copyright (�) Dmitry Belov, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub DLGN_main
{

 $DLGN_post1= $F{prmppk};
 $DLGN_post2= $F{prmpay};
 
 $FormText = '������ "���������� ��������" ��������� �������� ����� ������� � ������ ����� �� ������ ����.'.
             '' . $br2 .
             &bold('������� ������������ �������� ��� ���������� : ').
             &input_t('prmppk',$DLGN_post1,10,8,' autocomplete="off"').$br2.
             &bold('������� �����, ������� ������� ��������� ���������� ('.$gr.'): ').
             &input_t('prmpay',$DLGN_post2,20,18,' autocomplete="off"');
 
 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('���������� ��������')
   )
 );


 #���� �� �������� ������� �� ������ �����
 unless (defined $F{prmpay} && defined $F{prmppk})
   {
    #���������� ����� ����� �������
    $OUT.=&MessX($form,1);
    return;
   }


 #�������� �� ����� ��������
 &Error('�� ����� ������������ ���������� �������� � ���� ����������.',$EOUT) if length($DLGN_post1)<2 || length($DLGN_post1)>10;
 &Error('�� ����� ������������ ���������� �������� � ����� ��������.',$EOUT) if length($DLGN_post2)<1 || length($DLGN_post2)>20;
 #�������� �� ������������ (�������� ������ � �������)
 &Error('������������ ������������ �������.',$EOUT) if $DLGN_post1!~/^[0-9]+$/;
 &Error('������������ ������������ �������.',$EOUT) if $DLGN_post2!~/^[0-9]+$/;


 #���� ������� ������ �� ������������� ���������� ����
 $DLGN_post1id=substr($DLGN_post1,0,-1);
 #�������� ������� ������ �� ������������� ���������� ����
 $PRMP_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM `users` WHERE `id`=$DLGN_post1id AND `mid`=0");
 &Error('�������� � ��.') unless $PRMP_sql1;
 #������� ���� �� ����
 $PRMP_count1=$PRMP_sql1->{'COUNT(*)'};
 #������� ��������� ������������, ��� ������ ���������� ���� �� ���������
 &Error('�� ������� �������������� ������������ ��������� ��� ����������.') if $PRMP_count1 != 1;

 #�������� ���� ������ ����� �������� ����� ������ ���� - ������� ��������� ������������
 &Error('�� ������� ����� ������, ��� � ��� ���� �� �����.') if ($U{$Mid}{final_balance} - $DLGN_post2) < 0;

 #�� ���������

 #��������� ����� � ������� DLGN_post2 �� ������ ���������� ��������
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,-$DLGN_post2,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'','�� ������ ���������� ��������',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ���������� �������� (������ ��������) $DLGN_post2 $gr ��� ��� $DLGN_post1, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� ����������� �������� � ������� �������� (��������)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance-".$DLGN_post2." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid ����������� ������ ���������� �������� $DLGN_post2 $gr ��� ��� $DLGN_post1, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
    &Error("��������� ������ �������� �����. ���������� � �������������.",$EOUT);
   }

 #��������� ����� � ������� DLGN_post2 �� ������ ���������� �������� ������� � id=$DLGN_post1id
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($DLGN_post1id,$DLGN_post2,10,'',600,$Adm{id},INET_ATON('$RealIp'),'','�� ������ ���������� ��������',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ���������� �������� (������ ����������) $DLGN_post2 $gr ��� ��� $DLGN_post1, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� ����������� �������� � ������� �������� (����������)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$DLGN_post2." WHERE id=$DLGN_post1id LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid ����������� ������ ���������� �������� $DLGN_post2 $gr ��� ��� $DLGN_post1, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
    &Error("��������� ������ �������� �����. ���������� � �������������.",$EOUT);
   }
 
 # �������� ������ ����������, ���� ����� ������������ - ��� ����� ��������
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$DLGN_post1id OR mid=$DLGN_post1id");
 
 #�������� �������, ��� �� ���������
 &OkMess(&bold_br("���� � ������������ �������� ����� $DLGN_post1 �������� �� $DLGN_post2 $gr").'���� ������� ������� ���������� ��� ��������� ������� � �������� - ������ ���������� ����� ������� � ������� ���������� �����.'.$br2);


}

1;
