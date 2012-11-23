
 Модуль оплаты платёжной системой PayPal для биллинговой системы NoDeny 49/50.
 Copyright (с) Dzmitry Bialou, 2011

1. Установить необходимые порты:
# cd /usr/ports/security/p5-Net-SSLeay && make install clean

2. Скопировать файлы PayPal.pm, getppcert.pl, ipn.pl и test.pl в /usr/local/www/apache22/cgi-bin/paypal, дать права на выполнение:
# cd /usr/local/www/apache22/cgi-bin/paypal
# chmod +x ./*
# chown -v www:www ./*

3. Вписать плагин в реестр плагинов:
551		Spaypal			PL_main			PayPal		0       0

4. Дополнить list.cfg строками:
R - 			-	'Мерчант PayPal'
b PLPL_enabled          0       'Да - модуль PayPal включен'
s PLPL_account          0       'Ваш PayPal аккаунт (необходим Account Type: Personal и выше)'
s PLPL_currency         0       'Трехбуквенный код основной валюты Вашего счета PayPal'
s PLPL_currency_billing 0       'Трехбуквенный код локальная валюта биллинга (если пусто - без конверсии)'
s PLPL_ipn_url          0       'Относительный URL скрипта IPN-нотификации  (по умолчанию /cgi-bin/paypal/ipn.pl)'
s PLPL_cipher           10      'Шифр для кодирования и декодирования данных, рекомендуется около 30 символов'
b PLPL_show_logo        0       'Да - показывать лого PayPal сверху плагина'

5. Если необходимо показывать логотип PayPal - загрузить его в /usr/local/www/apache22/data/i/paypal/, дать права на чтение:
# cd /usr/local/www/apache22/data/i/paypal/
# chmod +r ./*
# chown -v www:www ./*

6. Настроить модуль и включить его. Обязательно проверить URL скрипта IPN-нотификации, чтобы IPN проходила без возврата в биллинг.

Валюты:
Algerian Dinar (DZD)
Argentine Peso (ARS)
Armenian Dram (AMD)
Australian Dollar (AUD)
Bahamian Dollar (BSD)
Bahraini Dinar (BHD)
Bangladeshi Taka (BDT)
Barbados Dollar (BBD)
Belarusian Ruble (BYR)
Belize Dollar (BZD)
Bermudian Dollar (BMD)
Bolivian Boliviano (BOB)
Botswana Pula (BWP)
Brazilian Real (BRL)
British Pound (GBP)
Brunei Dollar (BND)
Bulgarian Lev (BGN)
Burundi Franc (BIF)
Cambodian Riel (KHR)
Canadian Dollar (CAD)
Cape Verde Escudo (CVE)
Cayman Islands Dollar (KYD)
CFA BCEAO Franc (XOF)
CFA BEAC Franc (XAF)
CFP Franc (XPF)
Chilean Peso (CLP)
Chinese Yuan Renminbi (CNY)
Colombian Peso (COP)
Costa Rican Colon (CRC)
Croatian Kuna (HRK)
Cuban Peso (CUP)
Czech Koruna (CZK)
Danish Krone (DKK)
Djibouti Franc (DJF)
Dominican Peso (DOP)
East Caribbean Dollar (XCD)
Egyptian Pound (EGP)
Estonian Kroon (EEK)
Ethiopian Birr (ETB)
Euro (EUR)
Fiji Dollar (FJD)
Gambian Dalasi (GMD)
Ghanaian Cedi (GHS)
Guatemalan Quetzal (GTQ)
Haitian Gourde (HTG)
Honduran Lempira (HNL)
Hong Kong Dollar (HKD)
Hungarian Forint (HUF)
Iceland Krona (ISK)
Indian Rupee (INR)
Indonesian Rupiah (IDR)
Iranian Rial (IRR)
Iraqi Dinar (IQD)
Israeli New Shekel (ILS)
Jamaican Dollar (JMD)
Japanese Yen (JPY)
Jordanian Dinar (JOD)
Kazakhstan Tenge (KZT)
Kenyan Shilling (KES)
Korean Won (KRW)
Kuwaiti Dinar (KWD)
Lao Kip (LAK)
Latvian Lats (LVL)
Lebanese Pound (LBP)
Lesotho Loti (LSL)
Libyan Dinar (LYD)
Lithuanian Litas (LTL)
Macau Pataca (MOP)
Malawi Kwacha (MWK)
Malaysian Ringgit (MYR)
Mauritius Rupee (MUR)
Mexican Peso (MXN)
Moldovan Leu (MDL)
Moroccan Dirham (MAD)
Myanmar Kyat (MMK)
Nepalese Rupee (NPR)
Netherlands Antillian Guilder (ANG)
New Zealand Dollar (NZD)
Nicaraguan Cordoba Oro (NIO)
Nigerian Naira (NGN)
Norwegian Krone (NOK)
Omani Rial (OMR)
Pakistan Rupee (PKR)
Panamanian Balboa (PAB)
Paraguay Guarani (PYG)
Peruvian Nuevo Sol (PEN)
Philippine Peso (PHP)
Polish Zloty (PLN)
Qatari Rial (QAR)
Romanian Leu (RON)
Russian Ruble (RUB)
Rwanda Franc (RWF)
Saudi Riyal (SAR)
Serbian Dinar (RSD)
Seychelles Rupee (SCR)
Singapore Dollar (SGD)
Somali Shilling (SOS)
South African Rand (ZAR)
Sri Lanka Rupee (LKR)
Sudanese Dinar (SDD)
Swaziland Lilangeni (SZL)
Swedish Krona (SEK)
Swiss Franc (CHF)
Syrian Pound (SYP)
Taiwan Dollar (TWD)
Tanzanian Shilling (TZS)
Thai Baht (THB)
Trinidad and Tobago Dollar (TTD)
Tunisian Dinar (TND)
Turkish Lira (TRY)
Uganda Shilling (UGX)
Ukraine Hryvnia (UAH)
United Arab Emirates Dirham (AED)
Uruguay Peso (UYU)
US Dollar (USD)
Venezuelan Bolivar (VEF)
Vietnamese Dong (VND)
Zambian Kwacha (ZMK)
Zimbabwe Dollar (ZWD)

