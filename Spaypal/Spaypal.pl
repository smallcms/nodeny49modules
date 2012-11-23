#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Модуль оплаты платёжной системой PayPal
# Copyright (с) Dzmitry Bialou, 2011
# --------------------------------------------- 
#$VER=49.32;

use Digest::MD5 qw(md5_hex);

sub PL_main
{
 &Error($V ? 'Модуль не сконфигурирован в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) unless $PLPL_enabled && $PLPL_account && $PLPL_currency && $PLPL_ipn_url && $PLPL_cipher;
 &Error($V ? 'Модуль отключен в настройках биллинговой системы.' : 'Раздел недоступен.',$EOUT) unless $PLPL_enabled;
 # Название продукта для PayPal
 $PLPL_prodname=$Title_net;
 # Подгонка шифра для AES шифрования под 32 символа
 $PLPL_cipher=sprintf("%.32s",sprintf("% 32s", $PLPL_cipher));
 # Генерация новой рандомной сессии
 $PLPL_new_session=md5_hex(rand());

 # Показывать ли логотип PayPal
 if ($PLPL_show_logo) {
   $OUT.='<img src="'.$img_dir.'/paypal/PayPal_logo_150x65.gif" alt="">';
   }

 $PLPL_ppamount=$F{ppamount};
 $form=&div('cntr',
   &form('!'=>1,
     (
      &bold('Введите сумму пополнения счета: ').&input_t('ppamount',$PLPL_ppamount,8,7,' autocomplete="off"').' '.$PLPL_currency.
      &input_h('ppsession',$PLPL_new_session)
     ).$br2.&submit_a('Пополнить')
   )
 );

# Обнаружена переменная paypal, поэтому начнём обработку данных для зачисления суммы
 if (defined $F{paypal})
   {
    if ($F{paypal} == "1")
    {
    # Пользователь решил вернуться из PayPal в биллинг
    # Подключаются нужные .pm
    use lib "/usr/local/www/apache22/paypal";
    use Business::PayPal;
    my %query = %F;

    # Происходит проверка валидности пришедших извне данных
    # PayPal при проверке должен вернуть VERIFIED
    my $papid = $query{custom};
    my $paypal = Business::PayPal->new($papid);
    my ($txnstatus, $reason) = $paypal->ipnvalidate(\%query);
    # Что-то не так с данными, вероятнее всего это взломщик
    &ToLog("! mid $Mid использовал услугу PayPal. Подозрение на мошенничество!") unless $txnstatus;
    &Error($V ? "PayPal failed: $reason" : "Попытка обмана. Ваши данные отправлены администрации.") unless $txnstatus;
    # Дополнительная проверка, при которой PayPal присылает код VERIFIED, иначе это подделка
    if ($reason =~ /VERIFIED/ && $query{payment_status} =~ /Completed/)
      {
      #Проверка получателя платежа в PayPal
      &ToLog("! mid $Mid использовал услугу PayPal. Подозрение на мошенничество!") if $receiver_email != $PLPL_account;
      &Error($V ? "PayPal IPN failed" : "Попытка обмана. Ваши данные отправлены администрации.") if $receiver_email != $PLPL_account;
      # Декодирование полученных данных (получатель платежа, уникальная сессия, сумма)
      ($PLPL_Mid,$PLPL_ses,$PLPL_money) = &PLPL_AES_DECRYPT($query{custom});

      # Проверка: оплачен ли платёж ранее (например через скрипт ipn.pl)
      $PLPL_sql1=&sql_select_line($dbh,"SELECT COUNT(*) FROM pays WHERE `mid`=$PLPL_Mid AND `type` =10 AND `category` =8 AND `reason` ='$PLPL_ses'");
      &Error('проблема с БД.') unless $PLPL_sql1;
      $PLPL_sql_count1=$PLPL_sql1->{'COUNT(*)'};
      # Если услуга уже оплачена
      if ($PLPL_sql_count1 != 0)
      {
       # Не сообщаем пользователю, что мерчант мог быть инициирован через ipn и всё давно уже оплачено
       # Меньше знает - меньше дурацких вопросов
       &OkMess(&bold_br('Заявка была успешно оплачена.').'Если текущих средств достаточно для включения доступа в интернет - доступ будет включен в течение нескольких минут.');
       &Exit;
      } else {
               #Мерчант со стороны PayPal->ipn не произошёл. Оплата услуги прямо сейчас
               $sql="INSERT INTO pays (mid,cash,type,bonus,category,admin_id,admin_ip,reason,coment,time) ".
                    "VALUES($PLPL_Mid,$PLPL_money,10,'y',8,$Adm{id},INET_ATON('$RealIp'),'$PLPL_ses','Оплата через мерчант PayPal',$t)";
               $rows=&sql_do($dbh,$sql);
               &ToLog("! mid $Mid использовал услугу PayPal (запись зачисления) $PLPL_money $gr для id $PLPL_Mid, но произошла ошибка внесения платежа в таблицу платежей.") if $rows<1;

               #начинаем формировать внесение в таблицу платежей (зачисление)
               $rows=&sql_do($dbh,"UPDATE users SET balance=balance+".$PLPL_money." WHERE id=$PLPL_Mid LIMIT 1");
               if ($rows<1)
                 {
                   &ToLog("! mid $Mid использовал услугу PayPal $PLPL_money $gr для id $PLPL_Mid, но после внесения платежа в таблицу платежей произошла ошибка изменения баланса клиента");
                   &Error("Произошла ошибка зачисления суммы. Обратитесь к администрации.",$EOUT);
                 }
               # разрешим доступ получателю, если денег недостаточно - все равно отключит
               &sql_do($dbh,"UPDATE users SET state='on' WHERE id=$PLPL_Mid OR mid=$PLPL_Mid");               

               &OkMess(&bold_br('Заявка была успешно оплачена.').'Если текущих средств достаточно для включения доступа в интернет - доступ будет включен в течение нескольких минут.');
               &Exit;
              }

      } else {
       &ToLog("! mid $Mid использовал услугу PayPal. Подозрение на мошенничество!");
       &Error($V ? "PayPal IPN failed" : "Попытка обмана. Ваши данные отправлены администрации.");
      }

    return;
    }
    elsif ($F{paypal} == "2")
      {
      # Пользователь нажал в PayPal отмену платежа, сообщение пользователю об этом
      &PLPL_cancel;
      }
   }
 
 unless (defined $F{ppamount} && $F{ppsession})
   {
    $OUT.=&MessX($form,1);
    return;
   } 

$PLPL_session=$F{ppsession};

 # Проверки правильности ввода суммы
 # Проверки на длину символов
 &Error('Вы ввели неправильное количество символов в сумме обещанного платежа.',$EOUT) if length($PLPL_ppamount)<1 || length($PLPL_ppamount)>20;
 &Error('Ошибка сессии.',$EOUT) if length($PLPL_session) != 32;
 # Заменяется запятая на точку (иногда люди пишут запятую)
 $PLPL_ppamount=~s/,/./;
 &Error('Использованы недопустимые символы.',$EOUT) if $PLPL_ppamount!~/^[0-9.]+$/;


 # Информирование пользователя и форма отправки в PayPal
 $paypalform2='';
 $paypalform2.=&bold_br('При оплате будет произведена автоматическая конверсия валют!');
 # Форматирование цены в соответствии с требованиями PayPal (X.XX)
 $PLPL_ppamount=sprintf("%.2f",$PLPL_ppamount*1);
 $paypalform2.=&bold($PLPL_ppamount.' '.$PLPL_currency);
 # Если не нужно конвертировать - валюта PayPal=валюта NoDeny
 if (!$PLPL_currency_billing) {
   $PLPL_currency_billing_amount=$PLPL_ppamount;
   $paypalform2.=&bold(' будут зачислены на ваш счёт');
   } else {
     # Иначе валюта конвертируется функцией &PLPL_Conv_paypal_to_local
     $paypalform2.=&bold(' будут конвертированы в валюту биллинговой системы: ');
     $PLPL_currency_billing_amount=&PLPL_Conv_paypal_to_local($PLPL_currency,$PLPL_currency_billing,$PLPL_ppamount);
     # Если данные не поступили (например недоступен сайт конверсии), выводится ошибка, прекращается работа
     &Error($V ? "Ошибка получения данных из конвертера валют." : "Ошибка конверсии валют. Услуга временно недоступна.") if (!$PLPL_currency_billing_amount);
     $paypalform2.=&bold($PLPL_currency_billing_amount.' '.$PLPL_currency_billing);
     $paypalform2.=&bold(' и будут зачислены на ваш счёт');
     }
 # Происходит шифрование id пользователя, уникальной сессии и суммы платежа (уже сконвертированной по курсу)
 $PLPL_custom_value = &PLPL_AES_ENCRYPT($Mid,$PLPL_session,$PLPL_currency_billing_amount);

 $paypalform2.=$br2;
 # Формируется возвратные url для передачи в PayPal
 if ($ENV{HTTPS} && $ENV{HTTPS} == "on") {$paypalform2_proto='https://';} else {$paypalform2_proto='http://';}
 $paypalform2.='
 <form method="post" action="https://www.paypal.com/cgi-bin/webscr" enctype="multipart/form-data" onsubmit="javascript:document.getElementById(\'divPayPal\').innerHTML=\'<div class=message>Данные посланы. Ждите...</div>\';">
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
   <input type="submit" name="submit" value="Я соглашаюсь с условиями, продолжить оплату" />
   </div>
 </form>
 ';
 &Message_Exit($paypalform2);
}

# FEATURE! (фичя, удалить)
# Формирование выпадающего списка с названиями валют
# Возврат: выпадающий список
#sub PLPL_currency_in_list
#{
# my $currency="<select size=1 name=currency>";
# $currency.="<option value=EUR>EUR</option>";
# $currency.="<option value=USD>USD</option>"; 
# $currency.="</select>";
# return $currency;
#}

# Функция получения сконвертированной суммы
# Вызов: &PLPL_Conv_paypal_to_local(валюта_PayPal,валюта_биллинга,сумма)
# Возврат: сконвертированная валюта
sub PLPL_Conv_paypal_to_local
{
# Переменные для конвертера: адрес, порт, путь
# exchange-rates.org взят как наиболее удобный,
# но можно прикрутить почти любой
my $host = "www.exchange-rates.org";
#my $host = "localhost"; #fake_test_1
#my $host = "google.com";     #fake_test_2
my $port = "80";
#my $uri = "/test.html"; #uri_fake_test
my $uri = "/converter/$_[0]/$_[1]/";

# Получение данных сокетом
my $socket = IO::Socket::INET->new("$host:$port");
# Вывод на экран ошибки, через админку выводится причина ошибки
unless ($socket) {&Error($V ? "can't connect to HTTP server on $host:$port: $!" : 'Ошибка конверсии валют. Услуга временно недоступна.',$EOUT);}
$socket->autoflush(1);
# Притворяемся самым нежным и пушистым юзером
print $socket "GET $uri HTTP/1.1\nHost: $host\nUser-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)\nAccept: text/html\nConnection: close\nReferer: http://www.exchange-rates.org/converter.aspx\n\n";
my $answer;
# Чтение страницы в переменную и поиск нужных данных
while (<$socket>) {$answer.="$_";}
close $socket;

# Находится нужный тэг, опознали сконвертированное значение валюты
if ($answer =~ m/<span id=\"ctl00_M_lblToAmount\">([\d,.]+)<\/span>/)
  {
  my $curval = $1;
  $curval =~ s/,//;
  # Форматирование суммы до сотых, умножение на количество PayPal-едениц
  my $curval=sprintf("%.2f",$curval*$_[2]);
  #
  return $curval;
  }
}

# Функция кодирования передаваемых данных
# Вызов: &PLPL_AES_data(Mid_пользователя, уникальная_сессия_оплаты, сконвертированная_сумма_зачисления)
# Возврат e: ППК, сессия, сумма зашифрованные AES и закодированные в base64 (единая строка)
sub PLPL_AES_ENCRYPT
{
 use Crypt::Rijndael;
 use MIME::Base64;
 # Получение ППК
 my $csum=0;
 $csum+=$_ foreach split //,$_[0];
 $csum%=10;
 my $ppk="$_[0]$csum";
 # Подготовка к шифрованию ППК, сессии, суммы
 my $crypt_ppk=sprintf("% 32s", $ppk);
 my $crypt_ses=$_[1];
 my $crypt_sum=sprintf("% 32s", $_[2]);
 my $cipher = new Crypt::Rijndael $PLPL_cipher, Crypt::Rijndael::MODE_CBC;
 # Шифроване данных в AES
 my $crypt_ppk = $cipher->encrypt($crypt_ppk);
 my $crypt_ses = $cipher->encrypt($crypt_ses);
 my $crypt_sum = $cipher->encrypt($crypt_sum);

 # Дополнительно данные закрываются в base64, параметра после запятой - избавляемся от '\n'
 my $crypt_all = encode_base64($crypt_ppk.'___EOT'.$crypt_ses.'___EOT'.$crypt_sum, '');

 return $crypt_all;
}

# Функция декодирования передаваемых данных
# Вызов: &PLPL_AES_DECRYPT(данные_закодированные_в_base64)
# Возврат: декодированные Mid, сессия, сумма (три значения)
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
# Пользователь нажал в PayPal отмену платежа, сообщение пользователю об этом
 $OUT.=&Error('Оплата отменена. Сумма не была перечислена.');
 return;
}

1;

