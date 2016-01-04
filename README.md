# Содержание проекта
Бесплатные модули, хаки и патчи для биллинговой системы [NoDeny49](http://nodeny.com.ua/). Бесплатные аналоги платных модулей а так же разрабатываемые изначально открытые решения для этой биллинговой системы.

# Модули для nodeny
В настоящее время доступны следующие модули и патчи:

## Модуль "Графическое отображения загрузки канала"
Умеет:

* показывает загрузку канала клиента в виде графика
* Использует библиотеки highcharts и jquery

![hcharts](https://cloud.githubusercontent.com/assets/11487451/12089802/b5abc450-b2f9-11e5-95c9-17bdff19203e.png)

## Модуль "Поделиться балансом"
Умеет:

* устанавливать количество возможностей пользования услугой в месяц (опционально)
* устанавливать цену на услугу, снятие поисходит на стороне получателя (опционально)
* устанавливать минимальную сумму перевода
* устанавливать максимальную сумму перевода
* запрещать отдельным пользователям пользоваться услугой (опционально)
* защита от букв и прочих ненужных знаков и т.п. попыток хака
* ведёт лог в "платежах и событиях", управляется там же
* ведёт лог ошибок, если что-то с БД
* документирован
* настройки доступны из веб интерфейса администратора
* включает клиента, если после перевода положительный баланс
* многочисленные блокировки от злоупотреблений
* защита от неплательщиков и должников

![-66](https://cloud.githubusercontent.com/assets/11487451/12089819/d7634334-b2f9-11e5-8506-bf962ac7f053.png)

![-65](https://cloud.githubusercontent.com/assets/11487451/12089823/f1803c90-b2f9-11e5-936b-181b21aa8008.png)

![-60](https://cloud.githubusercontent.com/assets/11487451/12089826/0015dbfc-b2fa-11e5-9499-95ee0eab6eb0.png)

![-64](https://cloud.githubusercontent.com/assets/11487451/12089828/0628d986-b2fa-11e5-83e3-8b94a2986de7.png)

![-61](https://cloud.githubusercontent.com/assets/11487451/12089834/1551e498-b2fa-11e5-8de7-167825ef2dd7.png)


## Модуль "Обещанный платёж"
Умеет:

* устанавливать срок действия в днях (опционально)
* устанавливать количество возможностей пользования услугой в месяц (опционально)
* устанавливать цену на услугу (опционально)
* устанавливать минимальную цену платежа
* устанавливать максимальную цену платежа
* запрещать отдельным пользователям пользоваться услугой (опционально)
* защита от букв и прочих ненужных знаков, обновлений страниц и т.п. попыток хака
* пробрасывает 2 отдельных платежа (постоянный + временный), если указана плата за услугу
* ведёт лог в "платежах и событиях", управляется там же
* ведёт лог ошибок, если что-то с БД
* документирован
* настройки доступны из веб интерфейса администратора
* защита от платежа, при котором у клиента всё равно будет минус
* включает клиента, если после платежа положительный баланс

![-36](https://cloud.githubusercontent.com/assets/11487451/12089849/2d5bed68-b2fa-11e5-8388-02606032342b.png)
![-37](https://cloud.githubusercontent.com/assets/11487451/12089851/310e5d88-b2fa-11e5-9413-f0346a2abe3e.png)
 
## Патч для экспорта номеров карточек в CSV и печати в MS Access

![screenshot](https://cloud.githubusercontent.com/assets/11487451/12089791/a22fb60c-b2f9-11e5-8601-63995fc1cbdb.png)