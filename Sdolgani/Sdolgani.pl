#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (с) Volik Stanislav, 2008, 2009
# Copyright (с) Dmitry Belov, 2010
# Read license  http://nodeny.com.ua/license.txt
# --------------------------------------------- 
$VER=49.32;

sub DLGN_main
{

 $DLGN_post1= $F{prmppk};
 $DLGN_post2= $F{prmpay};
 
 $FormText = 'Услуга "Поделиться балансом" позволяет передать часть средств с вашего счёта на другой счёт.'.
             '' . $br2 .
             &bold('Введите персональный платёжный код получателя : ').
             &input_t('prmppk',$DLGN_post1,10,8,' autocomplete="off"').$br2.
             &bold('Введите сумму, которую желаете перевести получателю ('.$gr.'): ').
             &input_t('prmpay',$DLGN_post2,20,18,' autocomplete="off"');
 
 $form=&div('cntr',
   &form('!'=>1,
     $FormText.$br2.&submit_a('Поделиться балансом')
   )
 );


 #если из браузера клиента не пришла сумма
 unless (defined $F{prmpay} && defined $F{prmppk})
   {
    #Показываем форму ввода клиенту
    $OUT.=&MessX($form,1);
    return;
   }


 #проверка на длину символов
 &Error('Вы ввели неправильное количество символов в коде получателя.',$EOUT) if length($DLGN_post1)<2 || length($DLGN_post1)>10;
 &Error('Вы ввели неправильное количество символов в сумме перевода.',$EOUT) if length($DLGN_post2)<1 || length($DLGN_post2)>20;
 #проверка на корректность (работаем только с цифрами)
 &Error('Использованы недопостимые символы.',$EOUT) if $DLGN_post1!~/^[0-9]+$/;
 &Error('Использованы недопостимые символы.',$EOUT) if $DLGN_post2!~/^[0-9]+$/;


 #ищем учётную запись по персональному платежному коду
 $DLGN_post1id=substr($DLGN_post1,0,-1);
 #получаем учётную запись по персональному платежному коду
 $PRMP_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM `users` WHERE `id`=$DLGN_post1id AND `mid`=0");
 &Error('проблема с БД.') unless $PRMP_sql1;
 #считаем есть ли юзер
 $PRMP_count1=$PRMP_sql1->{'COUNT(*)'};
 #выводим сообщение пользователю, что такого платежного кода не существет
 &Error('Вы указали несуществующий персональный платежный код получателя.') if $PRMP_count1 != 1;

 #проверка если баланс минус введённая сумма меньше нуля - вывести сообщение пользователю
 &Error('Вы указали сумму больше, чем у Вас есть на счете.') if ($U{$Mid}{final_balance} - $DLGN_post2) < 0;

 #всё нормально

 #списываем сумму в размере DLGN_post2 за услугу Поделиться балансом
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($Mid,-$DLGN_post2,10,'y',105,$Adm{id},INET_ATON('$RealIp'),'','За услугу Поделиться балансом',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Поделиться балансом (запись списания) $DLGN_post2 $gr для ппк $DLGN_post1, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #начинаем формировать внесение в таблицу платежей (списание)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance-".$DLGN_post2." WHERE id=$Mid LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid использовал услугу Поделиться балансом $DLGN_post2 $gr для ппк $DLGN_post1, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
    &Error("Произошла ошибка перевода суммы. Обратитесь к администрации.",$EOUT);
   }

 #зачисляем сумму в размере DLGN_post2 за услугу Поделиться балансом клиенту с id=$DLGN_post1id
 $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
      "VALUES($DLGN_post1id,$DLGN_post2,10,'',600,$Adm{id},INET_ATON('$RealIp'),'','За услугу Поделиться балансом',$t)";

 $rows=&sql_do($dbh,$sql);
 &ToLog("! mid $Mid использовал услугу Поделиться балансом (запись зачисления) $DLGN_post2 $gr для ппк $DLGN_post1, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

 #начинаем формировать внесение в таблицу платежей (зачисление)
 $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$DLGN_post2." WHERE id=$DLGN_post1id LIMIT 1");
 if ($rows<1)
   {
    &ToLog("! mid $Mid использовал услугу Поделиться балансом $DLGN_post2 $gr для ппк $DLGN_post1, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
    &Error("Произошла ошибка перевода суммы. Обратитесь к администрации.",$EOUT);
   }
 
 # разрешим доступ получателю, если денег недостаточно - все равно отключит
 &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$DLGN_post1id OR mid=$DLGN_post1id");
 
 #сообщаем клиенту, что всё нормально
 &OkMess(&bold_br("Счет с персональным платёжным кодом $DLGN_post1 пополнен на $DLGN_post2 $gr").'Если текущих средств достаточно для включения доступа в интернет - доступ получателя будет включен в течение нескольких минут.'.$br2);


}

1;
