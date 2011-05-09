#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (�) Volik Stanislav, 2008, 2009
# Copyright (�) Dmitry Belov, 2010
# Copyright (c) Andrey Miroshnichenko, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub PRMP_main
{

 &Error($V ? '������ �� ��������������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) if !$PRMP_ld && !$PRMP_mxmo && !$PRMP_price && !$PRMP_mnp && !$PRMP_mxp;
 &Error($V ? '������ �������� � ���������� ����������� �������.' : '������ ����������.',$EOUT) if !$PRMP_enable;

 $PRMP_post= $F{prmpay};
 
 $FormText = '���� ��� ������ ������ � ����, � ��������� ���� ����������� ���, �������������� ������� &quot;��������� ������&quot;. '.
             '�� ������ ������� ��� ����� �������� ��������� ������, � �� ������� ���������� ������������ ������ ��������. '.
             '�� �������� ��������� ���� �� ��������� ����� �������� &quot;���������� �������&quot;. ����� ' . $PRMP_ld .' '. &PP_days($PRMP_ld) .
             ' ����� ���������, ����� &quot;���������� �������&quot; ����� ������������� ��������� ������� � ������ �����. ' . $br .
             &bold('������� ����� ���������� ������� (' .($PRMP_mnp+$PRMP_price).'...'.($PRMP_mxp+$PRMP_price).' '.$gr.'): ').&input_t('prmpay',$PRMP_post,20,18,' autocomplete="off"');
 # ������� �������� ��� ��� ���-���� ������� ������!
 $FormText .= $br2.'������������� �� ������������� ������ � ������� ����� ������� ����� � ������� '.&bold($PRMP_price.' '.$gr) if $PRMP_price > 0;
 
 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('���������')
   )
 );
 
 # ��������, ��������� �� ������������ ������������ ������?
 $PRMP_DenyToUseMod = 0; # �������� ��-���������.
 $PRMP_sql0=&sql_select_line($dbh,"SELECT field_value FROM dopdata WHERE parent_id=".$id." AND dopfield_id=".$PRMP_dopid." AND revision=(SELECT MAX(revision) from dopdata WHERE parent_id=".$id." AND dopfield_id=".$PRMP_dopid.")");
 if($PRMP_sql0) # ��� ��� �� ������������� �������� ����� ����������. ���� ���.�������� ������� �� ����������� - �� ������� 0. ���� ����������� - �� ������� �� 0 :)
 {
 	$PRMP_DenyToUseMod=$PRMP_sql0->{'field_value'}; # ��������� ��� ��������� �� ����. ��������, ����� ��������� ������. (����������� � 1)	
 } 
 &Error('�� �� ������ ��������������� ������ �������. ���������� � ���������� ��������������') if $PRMP_DenyToUseMod == 1;
 
 #��������, �� ������ �� ������� � ������������ ����?
 $PRMP_balanceLimit = ($PRMP_overdebt == 1 ) ? $pm->{limit_balance} : 0;
 &Error('�� �� ������ ��������������� ������ ������� �� ������� ����� ������� �������������. ���������� � ���������� ��������������') if($U{$Mid}{final_balance} - $PRMP_price + $PRMP_mxp < $PRMP_balanceLimit); 

 #�������� ���������� ������������� ������ �� ��������� PRMP_ld ����
 $PRMP_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =50 AND `category` =900 AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $PRMP_ld ) )");
 &Error('�������� � ��.') unless $PRMP_sql1;
 #������� ���������� ������������� ������
 $PRMP_count1=$PRMP_sql1->{'COUNT(*)'};
 #������� ��������� ������������, ������� ������ ������� �������
 &Error('�� ��� ������������ ������ &quot;��������� ������&quot; �����, ��� ' . $PRMP_ld . ' ' .&PP_days($PRMP_ld). ' �����.') if $PRMP_count1 > 0 && $PRMP_ld != 0;

 #�������� ���������� ������������� ������ � ���� ������
 $PRMP_sql2=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =50 AND `category` =900 AND `time` > UNIX_TIMESTAMP( DATE_FORMAT( NOW( ) , '%Y-%m-01' ) )");
 &Error('�������� � ��.') unless $PRMP_sql2;
 #������� ���������� ������������� ������
 $PRMP_count2=$PRMP_sql2->{'COUNT(*)'};
 #������� ��������� ������������, ������� ������ ������� �������
 &Error('�� ��� ������������ ������ &quot;��������� ������&quot; � ���� ������ ����������� ���������� ���������� ���.') if $PRMP_count2 >= $PRMP_mxmo && $PRMP_mxmo != 0;

 #�������� ����� ��� ������ ��������� ������. ���� �����, ��� ���� ����� - ��������� ������
 if ($PRMP_oldpay) {
   $PRMP_sql3=&sql_select_line($dbh,"SELECT COUNT(*) FROM `pays` WHERE `mid`=$Mid AND `cash`>0 AND `time`>UNIX_TIMESTAMP( SUBDATE( NOW( ) , $PRMP_oldpay)) AND `type`='10'");
   &Error('�������� � ��.') unless $PRMP_sql3;
   #������� ���������� �������� �� ������
   $PRMP_count3=$PRMP_sql3->{'COUNT(*)'};
   #������� ��������� ������������, ������� ������ ������� �������
   &Error('�� ��������� ��� ���� �����, ��� ' . $PRMP_oldpay . ' ' .&PP_days($PRMP_ld). ' �����. ������ &quot;��������� ������&quot; ��� ��� ���������.') if $PRMP_oldpay !=0 && $PRMP_count3 < 1;
 }

 #���� �� �������� ������� �� ������ �����
 unless (defined $F{prmpay})
   {
    #���������� ����� ����� �������
    $OUT.=&MessX($form,1);
    return;
   }

 #�������� �� ����� ��������
 &Error('�� ����� ������������ ���������� �������� � ����� ���������� �������.',$EOUT) if length($PRMP_post)<1 || length($PRMP_post)>20;
 #�������� �� ������������ (�������� ������ � �������)
 &Error('������������ ������������ �������.',$EOUT) if $PRMP_post!~/^[0-9]+$/;
 #�������� �� ����������� �����
 &Error('����� ���������� ������� ������� ������ ���������� ����������.',$EOUT) if $PRMP_post<($PRMP_mnp+$PRMP_price);
 #�������� �� ������������ �����
 &Error('����� ���������� ������� ������� ������ ����������� ���������� (' . ($PRMP_mxp+$PRMP_price) . ').',$EOUT) if $PRMP_post>($PRMP_mxp+$PRMP_price);
 #�������� ���� �������� ����� + ������ �� ����� ������ ���� - ������� ��������� ������������
 &Error('���� ����� ������������, ����� ���������� ������������ ��������! � ��� ����� ������� ������������� ����. �������� �������������!') if ($PRMP_post - $PRMP_price + $U{$Mid}{final_balance}) < $PRMP_balanceLimit;

 #�� ���������

 #���� ������� ��������� ����� �� ������
 if ($PRMP_price > 0)
   {
    #��������� ����� � ������� PRMP_price �� ������ ��������� ������
    $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
         "VALUES($Mid,-$PRMP_price,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'','�� ������ ��������� ������',$t)";

    $rows=&sql_do($dbh,$sql);
    &ToLog("! mid $Mid ����������� ������ ��������� ������ (������ ��������) $PRMP_post $gr, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;
   }

 #�������� ����������� ��������� �����
 #������ ���������� ������� ��������� ������� (������� ����� + ���������� ����� �� �������)
 #���� ����� �������, ������� ���� - ����� ����. ������, ��������
 $time=$t+$PRMP_ld*3600*24;

 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,$PRMP_post,20,'y',1000,$Adm{id},INET_ATON('$RealIp'),'','��������� ������',$time)";
 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ��������� ������ $PRMP_post $gr, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� ����������� ������� 900, ������� ����� ����������� ��������� ��������������� �������
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,'',50,'',900,$Adm{id},INET_ATON('$RealIp'),'','��������� ������',$t)";
 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid ����������� ������ ��������� ������ (����������� ������) $PRMP_post $gr, �� ��������� ������ �������� ������� � ������� ��������.") if $rows<1;

 #�������� �� ����� ������� ��������� ������, �.�. ����� �� ������ �����
 $PRMP_posttmp = $PRMP_post - $PRMP_price;

 #�������� ����������� �������� � ������� ��������
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$PRMP_posttmp." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid ����������� ������ ��������� ������ $PRMP_post $gr, �� ����� �������� ������� � ������� �������� ��������� ������ ��������� ������� �������");
    &Error("��������� ������ ���������� �����. ���������� � �������������.",$EOUT);
   }
 
 # �������� ������, ���� ����� ������������ - ��� ����� ��������
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$Mid OR mid=$Mid");
 
 #�������� �������, ��� �� ���������
 &OkMess(&bold_br($PRMP_price!=0 ? "��� ���� �������� �� $PRMP_post $gr �� ��� $PRMP_price �������� �� ������ ������ &quot;��������� ������&quot;" : "��� ���� �������� �� $PRMP_post $gr").'���� ������� ������� ���������� ��� ��������� ������� � �������� - ������ ����� ������� � ������� ���������� �����.'.$br2);

}

#������������ ��� ������ ��������� �������� ����
sub PP_days {
	$days_10 = $_[0] % 10;
 	if($days_10 == 1) { return '����'; }
 	elsif($days_10 > 1 && $days_10 < 5) { return '���'; }
 	else { return '����'; }
}

1;

