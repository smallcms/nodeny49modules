#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (с) Volik Stanislav, 2008, 2009
# Copyright (с) Dmitry Belov, 2010
# Copyright (c) Andrey Miroshnichenko, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub PRMP_main
{

 &Error($V ? 'Модуль не сконфигурирован в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) if !$PRMP_ld && !$PRMP_mxmo && !$PRMP_price && !$PRMP_mnp && !$PRMP_mxp;
 &Error($V ? 'Модуль отключен в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) if !$PRMP_enable;

 $PRMP_post= $F{prmpay};
 
 $FormText = 'Если Ваш баланс близок к нулю, а пополнить счет возможности нет, воспользуйтесь услугой &quot;Обещанный платеж&quot;. '.
             'По Вашему запросу Вам будет зачислен временный платеж, и Вы сможете продолжать пользоваться нашими услугами. '.
             'Не забудьте пополнить счет до истечения срока действия &quot;обещанного платежа&quot;. Через ' . $PRMP_ld .' '. &PP_days($PRMP_ld) .
             ' после активации, сумма &quot;обещанного платежа&quot; будет автоматически полностью списана с Вашего счета. ' . $br .
             &bold('Введите сумму обещанного платежа (' .($PRMP_mnp+$PRMP_price).'...'.($PRMP_mxp+$PRMP_price).' '.$gr.'): ').&input_t('prmpay',$PRMP_post,20,18,' autocomplete="off"');
 # Добавим писюльку что это вся-таки платная услуга!
 $FormText .= $br2.'Дополнительно за использование услуги с платежа будет списана сумма в размере '.&bold($PRMP_price.' '.$gr) if $PRMP_price > 0;
 
 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('Пополнить')
   )
 );
 
 # Проверим, запрещено ли пользователю использовать услугу?
 $PRMP_DenyToUseMod = 0; # Разрешим по-умолчанию.
 $PRMP_sql0=&sql_select_line($dbh,"SELECT field_value FROM dopdata WHERE parent_id=".$id." AND dopfield_id=".$PRMP_dopid." AND revision=(SELECT MAX(revision) from dopdata WHERE parent_id=".$id." AND dopfield_id=".$PRMP_dopid.")");
 if($PRMP_sql0) # Тут как бы неоднозначная ситуация может возникнуть. Если доп.параметр никогда не определялся - то вернётся 0. Если определялся - то вернётся не 0 :)
 {
 	$PRMP_DenyToUseMod=$PRMP_sql0->{'field_value'}; # Посмотрим что вернулось из базы. Возможно, нужно запретить доступ. (Установится в 1)	
 } 
 &Error('Вы не можете воспользоваться данной услугой. Обратитесь к системному администратору') if $PRMP_DenyToUseMod == 1;
 
 #проверим, не сильно ли большой у пользователя долг?
 $PRMP_balanceLimit = ($PRMP_overdebt == 1 ) ? $pm->{limit_balance} : 0;
 &Error('Вы не можете воспользоваться данной услугой по причине очень большой задолженности. Обратитесь к системному администратору') if($U{$Mid}{final_balance} - $PRMP_price + $PRMP_mxp < $PRMP_balanceLimit); 

 #проверим количество использований услуги за последние PRMP_ld дней
 $PRMP_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =50 AND `category` =900 AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $PRMP_ld ) )");
 &Error('проблема с БД.') unless $PRMP_sql1;
 #считаем количество использований услуги
 $PRMP_count1=$PRMP_sql1->{'COUNT(*)'};
 #выводим сообщение пользователю, который вконец потерял совесть
 &Error('Вы уже использовали услугу &quot;Обещанный платеж&quot; менее, чем ' . $PRMP_ld . ' ' .&PP_days($PRMP_ld). ' назад.') if $PRMP_count1 > 0 && $PRMP_ld != 0;

 #проверим количество использований услуги в этом месяце
 $PRMP_sql2=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =50 AND `category` =900 AND `time` > UNIX_TIMESTAMP( DATE_FORMAT( NOW( ) , '%Y-%m-01' ) )");
 &Error('проблема с БД.') unless $PRMP_sql2;
 #считаем количество использований услуги
 $PRMP_count2=$PRMP_sql2->{'COUNT(*)'};
 #выводим сообщение пользователю, который вконец потерял совесть
 &Error('Вы уже использовали услугу &quot;Обещанный платеж&quot; в этом месяце максимально допустимое количество раз.') if $PRMP_count2 >= $PRMP_mxmo && $PRMP_mxmo != 0;

 #проверим когда был сделан последний платеж. если более, чем дней назад - запрещаем услугу
 if ($PRMP_oldpay) {
   $PRMP_sql3=&sql_select_line($dbh,"SELECT COUNT(*) FROM `pays` WHERE `mid`=$Mid AND `cash`>0 AND `time`>UNIX_TIMESTAMP( SUBDATE( NOW( ) , $PRMP_oldpay)) AND `type`='10'");
   &Error('проблема с БД.') unless $PRMP_sql3;
   #считаем количество платажей за период
   $PRMP_count3=$PRMP_sql3->{'COUNT(*)'};
   #выводим сообщение пользователю, который вконец потерял совесть
   &Error('Вы пополняли Ваш счёт более, чем ' . $PRMP_oldpay . ' ' .&PP_days($PRMP_ld). ' назад. Услуга &quot;Обещанный платеж&quot; для Вас отключена.') if $PRMP_oldpay !=0 && $PRMP_count3 < 1;
 }

 #если из браузера клиента не пришла сумма
 unless (defined $F{prmpay})
   {
    #Показываем форму ввода клиенту
    $OUT.=&MessX($form,1);
    return;
   }

 #проверка на длину символов
 &Error('Вы ввели неправильное количество символов в сумме обещанного платежа.',$EOUT) if length($PRMP_post)<1 || length($PRMP_post)>20;
 #проверка на корректность (работаем только с цифрами)
 &Error('Использованы недопустимые символы.',$EOUT) if $PRMP_post!~/^[0-9]+$/;
 #проверка на минимальный платёж
 &Error('Сумма обещанного платежа указана меньше минимально допустимой.',$EOUT) if $PRMP_post<($PRMP_mnp+$PRMP_price);
 #проверка на максимальный платёж
 &Error('Сумма обещанного платежа указана больше максимально допустимой (' . ($PRMP_mxp+$PRMP_price) . ').',$EOUT) if $PRMP_post>($PRMP_mxp+$PRMP_price);
 #проверка если введённая сумма + баланс всё равно меньше нуля - вывести сообщение пользователю
 &Error('Этой суммы недостаточно, чтобы продолжить пользоваться услугами! У вас очень большой отрицательный счёт. Погасите задолженность!') if ($PRMP_post - $PRMP_price + $U{$Mid}{final_balance}) < $PRMP_balanceLimit;

 #всё нормально

 #если указано списывать сумму за услугу
 if ($PRMP_price > 0)
   {
    #списываем сумму в размере PRMP_price за услуги Обещанный платеж
    $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
         "VALUES($Mid,-$PRMP_price,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'','За услугу Обещанный платеж',$t)";

    $rows=&sql_do($dbh,$sql);
    &ToLog("! mid $Mid использовал услугу Обещанный платеж (запись списания) $PRMP_post $gr, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;
   }

 #начинаем формировать временный платёж
 #создаём переменную времени окончания платежа (текущее время + количество суток из конфига)
 #если нужно удвоить, утроить срок - цифры ниже. множте, плюсуйте
 $time=$t+$PRMP_ld*3600*24;

 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,$PRMP_post,20,'y',1000,$Adm{id},INET_ATON('$RealIp'),'','Обещанный платеж',$time)";
 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Обещанный платеж $PRMP_post $gr, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #начинаем формировать собитие 900, которое будет блокировать повторные злоупотребления модулем
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,'',50,'',900,$Adm{id},INET_ATON('$RealIp'),'','Обещанный платеж',$t)";
 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Обещанный платеж (блокирующая запись) $PRMP_post $gr, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #отнимаем от суммы платежа стоимость услуги, т.к. сняли за услугу ранее
 $PRMP_posttmp = $PRMP_post - $PRMP_price;

 #начинаем формировать внесение в таблицу платежей
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$PRMP_posttmp." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid использовал услугу Обещанный платеж $PRMP_post $gr, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
    &Error("Произошла ошибка пополнения счета. Обратитесь к администрации.",$EOUT);
   }
 
 # разрешим доступ, если денег недостаточно - все равно отключит
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$Mid OR mid=$Mid");
 
 #сообщаем клиенту, что всё нормально
 &OkMess(&bold_br($PRMP_price!=0 ? "Ваш счет пополнен на $PRMP_post $gr из них $PRMP_price удержано на оплату услуги &quot;Обещанный платеж&quot;" : "Ваш счет пополнен на $PRMP_post $gr").'Если текущих средств достаточно для включения доступа в интернет - доступ будет включен в течение нескольких минут.'.$br2);

}

#подпрограмма для вывода красивого названия дней
sub PP_days {
	$days_10 = $_[0] % 10;
 	if($days_10 == 1) { return 'день'; }
 	elsif($days_10 > 1 && $days_10 < 5) { return 'дня'; }
 	else { return 'дней'; }
}

1;

