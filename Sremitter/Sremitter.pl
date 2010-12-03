#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (с) Volik Stanislav, 2008, 2009
# Copyright (с) Dmitry Belov, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub RMTR_main
{


 &Error($V ? 'Модуль не сконфигурирован в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) if !$RMTR_price && !$RMTR_mnbap && !$RMTR_minsrc && !$RMTR_minsrc && !$RMTR_maxsrc && !$RMTR_maxdst && !$RMTR_ntrvlsrc && !$RMTR_ntrvldst && !$RMTR_dopid && !$RMTR_overdebt && !$RMTR_oldpay;
 &Error($V ? 'Модуль отключен в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) if !$RMTR_enable;

 $RMTR_post1= $F{rmtrpk};
 $RMTR_post2= $F{rmtray};
 
 $FormText = 'Услуга "Поделиться балансом" позволяет передать часть средств с вашего счёта на другой счёт.'.
             '' . $br2 .
             &bold('Введите персональный платёжный код получателя : ').
             &input_t('rmtrpk',$RMTR_post1,10,8,' autocomplete="off"').$br2.
             &bold('Введите сумму, которую желаете перевести получателю (' .($RMTR_minsrc+$RMTR_price).'...'.($RMTR_maxsrc+$RMTR_price).' '.$gr.'): ').
             &input_t('rmtray',$RMTR_post2,20,18,' autocomplete="off"');
 #добавим писюльку что это вся-таки платная услуга!
 $FormText .= $br2.'Дополнительно за использование услуги с платежа на стороне получателя будет списана сумма в размере '.&bold($RMTR_price.' '.$gr) if $RMTR_price > 0;

 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('Поделиться балансом')
   )
 );

 #проверим, запрещено ли пользователю использовать услугу?
 $RMTR_DenyToUseMod = 0; # Разрешим по-умолчанию.
 $RMTR_sql0=&sql_select_line($dbh,"SELECT field_value FROM dopdata WHERE parent_id=".$id." AND dopfield_id=".$RMTR_dopid." AND revision=(SELECT MAX(revision) from dopdata WHERE parent_id=".$id." AND dopfield_id=".$RMTR_dopid.")");
 if($RMTR_sql0) # Тут как бы неоднозначная ситуация может возникнуть. Если доп.параметр никогда не определялся - то вернётся 0. Если определялся - то вернётся не 0 :)
 {
 	$RMTR_DenyToUseMod=$RMTR_sql0->{'field_value'}; # Посмотрим что вернулось из базы. Возможно, нужно запретить доступ. (Установится в 1)	
 } 
 &Error('Вы не можете воспользоваться данной услугой. Обратитесь к системному администратору') if $RMTR_DenyToUseMod == 1;

 #проверим количество использований услуги за последние RMTR_ntrvlsrc дней
 $RMTR_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$Mid AND `type` =10 AND `category` =105 AND `reason` = 'За услугу Поделиться балансом' AND `coment` ='За услугу Поделиться балансом' AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_ntrvlsrc ) )");
 &Error('проблема с БД.') unless $RMTR_sql1;
 #считаем количество использований услуги
 $RMTR_count1=$RMTR_sql1->{'COUNT(*)'};
 #выводим сообщение пользователю
 &Error('Вы уже использовали услугу &quot;Поделиться балансом&quot; менее, чем ' . $RMTR_ntrvlsrc . ' ' .&PP_days($RMTR_ntrvlsrc). ' назад.') if $RMTR_count1 > 0 && $RMTR_ntrvlsrc != 0;


 #если из браузера клиента не пришла сумма
 unless (defined $F{rmtray} && defined $F{rmtrpk})
   {
    #показываем форму ввода клиенту
    $OUT.=&MessX($form,1);
    return;
   }


 #проверка на длину символов
 &Error('Вы ввели неправильное количество символов в коде получателя.',$EOUT) if length($RMTR_post1)<2 || length($RMTR_post1)>10;
 &Error('Вы ввели неправильное количество символов в сумме перевода.',$EOUT) if length($RMTR_post2)<1 || length($RMTR_post2)>20;
 #проверка на корректность (работаем только с цифрами)
 &Error('Использованы недопостимые символы.',$EOUT) if $RMTR_post1!~/^[0-9]+$/;
 &Error('Использованы недопостимые символы.',$EOUT) if $RMTR_post2!~/^[0-9]+$/;

 #проверка на остаточный минимум после перевода
 &Error('Ваш баланс после перевода суммы получателю не должен быть меньше '.$RMTR_mnbap.' '.$gr,$EOUT) if $U{$Mid}{balance}-$RMTR_post2 < $RMTR_mnbap && $RMTR_mnbap !=0;
 #проверка на минимальный платёж
 &Error('Сумма перевода указана меньше минимально допустимой.',$EOUT) if $RMTR_post2 < $RMTR_minsrc+$RMTR_price && $RMTR_minsrc != 0;
 #проверка на максимальный платёж
 &Error('Сумма перевода указана больше максимально допустимой (' . ($RMTR_maxsrc+$RMTR_price) . ').',$EOUT) if $RMTR_post2 > $RMTR_maxsrc+$RMTR_price && $RMTR_maxsrc != 0;

 #ищем учётную запись по персональному платежному коду
 $RMTR_post1id=substr($RMTR_post1,0,-1);

 #получаем учётную запись по персональному платежному коду
 $RMTR_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM `users` WHERE `id`=$RMTR_post1id AND `mid`=0");
 &Error('проблема с БД.') unless $RMTR_sql1;
 #считаем есть ли юзер
 $RMTR_count1=$RMTR_sql1->{'COUNT(*)'};
 #выводим сообщение пользователю, что такого платежного кода не существет
 &Error('Вы указали несуществующий персональный платежный код получателя.') if $RMTR_count1 != 1;

 #получаем сумму платежей-переводов учётной записи по персональному платежному коду
 $RMTR_sql2=&sql_select_line($dbh,"SELECT SUM(`cash`) AS `cash` FROM `pays` WHERE `mid`=$RMTR_post1id AND `type` =10 AND `category` =600 AND `reason` = 'За услугу Поделиться балансом' AND `coment` ='За услугу Поделиться балансом' AND `time` > UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_ntrvldst ) )");
 &Error('проблема с БД.') unless $RMTR_sql2;
 #забираем значение суммы
 $RMTR_maxdst_sql=$RMTR_sql2->{cash};
 #выводим сообщение пользователю, что получатель уже набил карманы доверху
 &Error('На балансе получателя уже имеется максимально возможная сумма.') if $RMTR_maxdst_sql >= $RMTR_maxdst && $RMTR_maxdst !=0;

 #получаем наличные платежи учётной записи по персональному платежному коду (кроме ремиттерных переводов)
 $RMTR_sql3=&sql_select_line($dbh,"SELECT COUNT(*) FROM `pays` WHERE `mid`=$RMTR_post1id AND `cash`>0 AND `type` ='10' AND `category` ='600' AND `reason` !='За услугу Поделиться балансом' AND `coment` !='За услугу Поделиться балансом' AND `time`>UNIX_TIMESTAMP( SUBDATE( NOW( ) , $RMTR_oldpay))");
 &Error('проблема с БД.') unless $RMTR_sql3;
 #забираем значение суммы
 $RMTR_oldpay_sql=$RMTR_sql3->{'COUNT(*)'};
 #выводим сообщение пользователю, что получатель давно забил на интернет
 &Error('Получатель очень давно не пополнял свой счёт.') if $RMTR_oldpay_sql < 1 && $RMTR_oldpay !=0;

 #получаем баланс учётной записи по персональному платежному коду
 $RMTR_sql4=&sql_select_line($dbh,"SELECT `balance` FROM `users` WHERE `id`=$RMTR_post1id AND `mid` =0");
 &Error('проблема с БД.') unless $RMTR_sql4;
 #забираем значение суммы
 $RMTR_overdebt_sql=$RMTR_sql4->{balance};
 #выводим сообщение пользователю, что получатель ушёл в большой минус
 &Error('На счете получателя слишком большая задолженность.') if $RMTR_overdebt_sql <= $RMTR_overdebt && $RMTR_overdebt !=0;

 #проверка если баланс минус введённая сумма меньше нуля - вывести сообщение пользователю
 &Error('Вы указали сумму больше, чем у Вас есть на счете.') if ($U{$Mid}{final_balance} - $RMTR_post2) < 0;

 #всё нормально

 #списываем сумму в размере RMTR_post2 за услугу Поделиться балансом
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,-$RMTR_post2,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'За услугу Поделиться балансом','За услугу Поделиться балансом',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Поделиться балансом (запись списания) $RMTR_post2 $gr для ппк $RMTR_post1, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #начинаем формировать внесение в таблицу платежей (списание)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance-".$RMTR_post2." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid использовал услугу Поделиться балансом $RMTR_post2 $gr для ппк $RMTR_post1, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
    &Error("Произошла ошибка перевода суммы. Обратитесь к администрации.",$EOUT);
   }

 #отнимаем от суммы перевода стоимость услуги
 $RMTR_post2_tmp = $RMTR_post2 - $RMTR_price;

 #если указано списывать сумму за услугу
 if ($RMTR_price > 0)
   {
     #списываем сумму в размере RMTR_price за услугу Поделиться балансом
     $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
         "VALUES($RMTR_post1id,-$RMTR_price,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'За услугу Поделиться балансом','За услугу Поделиться балансом',$t)";

     $rows=&sql_do($dbh,$sql);
     &ToLog("! mid $Mid использовал услугу Поделиться балансом (запись стоимости) $RMTR_price $gr для ппк $RMTR_post1, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;
   }

 #зачисляем сумму в размере RMTR_post2-RMTR_price за услугу Поделиться балансом клиенту с id=$RMTR_post1id
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($RMTR_post1id,$RMTR_post2,10,'',600,$Adm{id},INET_ATON('$RealIp'),'За услугу Поделиться балансом','За услугу Поделиться балансом',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Поделиться балансом (запись зачисления) $RMTR_post2 $gr для ппк $RMTR_post1, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #начинаем формировать внесение в таблицу платежей (зачисление)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$RMTR_post2_tmp." WHERE id=$RMTR_post1id LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid использовал услугу Поделиться балансом $RMTR_post2_tmp $gr для ппк $RMTR_post1, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
    &Error("Произошла ошибка перевода суммы. Обратитесь к администрации.",$EOUT);
   }
 
 # разрешим доступ получателю, если денег недостаточно - все равно отключит
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$RMTR_post1id OR mid=$RMTR_post1id");
 
 #сообщаем клиенту, что всё нормально
 &OkMess(&bold_br("Счет с персональным платёжным кодом $RMTR_post1 пополнен на $RMTR_post2_tmp $gr").'Если текущих средств достаточно для включения доступа в интернет - доступ получателя будет включен в течение нескольких минут.'.$br2);


}

#подпрограмма для вывода красивого названия дней
sub PP_days {
	$days_10 = $_[0] % 10;
 	if($days_10 == 1) { return 'день'; }
 	elsif($days_10 > 1 && $days_10 < 5) { return 'дня'; }
 	else { return 'дней'; }
}

1;
