Модуль "Графическое отображения загрузки канала" для биллинговой системы NoDeny 49.32

Умеет:

    * показывает загрузку канала клиента в виде графика
    * Использует библиотеки highcharts и jquery

Инструкция по установке:

1. Загрузить Sdetailtrafhc.pl на сервер в каталог:
/usr/local/nodeny/web

2. Прописать в реестре плагинов (файл /usr/local/nodeny/web/plugin_reestr.cfg), например так:
118		Sdetailtrafhc		TSHC_main		Трафик (графики)				0		0

3. Браузером в биллинге зайти в Операции -> Настройки -> Список плагинов. Вписать где хочется
Sdetailtrafhc

4. Создать в корне сайта (по-умолчанию /usr/local/www/apache22/data/) следующие пути:
/js/jquery/1.7.1/
/js/hc/

5. Выгрузить библиотеку jquery с сайта http://code.jquery.com/jquery-1.7.1.min.js и поместить в подкаталог
../js/jquery/1.7.1/

6. Выгрузить библиотеку highcharts с сайта http://code.highcharts.com/highcharts.js и поместить в подкаталог
../js/hc/

ВНИМАНИЕ!!! Библиотека highcharts распространяется по лицензии Creative Commons Attribution-NonCommercial 3.0 License
и доступна бесплатно ТОЛЬКО ДЛЯ НЕКОММЕРЧЕСКОГО ИСПОЛЬЗОВАНИЯ! Цены для использования извлечения прибыли доступны по
этой ссылке: http://www.highcharts.com/license

