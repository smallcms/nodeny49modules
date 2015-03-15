# Содержание проекта #

**Бесплатные модули**, хаки и патчи для **биллинговой системы** [NoDeny49](http://nodeny.com.ua/). **Бесплатные** аналоги платных **модулей** а так же разрабатываемые изначально открытые решения для этой **биллинговой системы**.

# Модули для nodeny #

В настоящее время доступны следующие **модули** и патчи:

> ### Модуль "Графическое отображения загрузки канала" ###

Умеет:

  * показывает загрузку канала клиента в виде графика
  * Использует библиотеки highcharts и jquery

![https://lh5.googleusercontent.com/-WhZZcINrEhw/T6sUPeQgHpI/AAAAAAAABKI/iVrZYrQeLJc/s1152/hcharts.png](https://lh5.googleusercontent.com/-WhZZcINrEhw/T6sUPeQgHpI/AAAAAAAABKI/iVrZYrQeLJc/s1152/hcharts.png)

> ### Модуль "Поделиться балансом" ###

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

![http://lh5.ggpht.com/_VQNegiUKCNA/TP6XuwTLkGI/AAAAAAAAAuw/QLg4nFvynco/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-66.png](http://lh5.ggpht.com/_VQNegiUKCNA/TP6XuwTLkGI/AAAAAAAAAuw/QLg4nFvynco/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-66.png)
![http://lh4.ggpht.com/_VQNegiUKCNA/TP6XujvrV8I/AAAAAAAAAus/QEk5SeK5YjM/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-65.png](http://lh4.ggpht.com/_VQNegiUKCNA/TP6XujvrV8I/AAAAAAAAAus/QEk5SeK5YjM/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-65.png)
![http://lh5.ggpht.com/_VQNegiUKCNA/TPmEpi09i6I/AAAAAAAAAuU/rqUX8iiBnsg/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-60.png](http://lh5.ggpht.com/_VQNegiUKCNA/TPmEpi09i6I/AAAAAAAAAuU/rqUX8iiBnsg/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-60.png)
![http://lh4.ggpht.com/_VQNegiUKCNA/TP6Xug4faNI/AAAAAAAAAuo/IXrUEDydWPE/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-64.png](http://lh4.ggpht.com/_VQNegiUKCNA/TP6Xug4faNI/AAAAAAAAAuo/IXrUEDydWPE/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-64.png)
![http://lh3.ggpht.com/_VQNegiUKCNA/TPmEpsDnxwI/AAAAAAAAAuY/-Qt9-IEvj3Q/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-61.png](http://lh3.ggpht.com/_VQNegiUKCNA/TPmEpsDnxwI/AAAAAAAAAuY/-Qt9-IEvj3Q/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-61.png)

> ### Модуль "Обещанный платёж" ###


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
![http://lh6.ggpht.com/_VQNegiUKCNA/TNBOYLlRpzI/AAAAAAAAAr4/qumnUFMG0eE/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-36.png](http://lh6.ggpht.com/_VQNegiUKCNA/TNBOYLlRpzI/AAAAAAAAAr4/qumnUFMG0eE/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA-36.png)
![http://lh3.ggpht.com/_VQNegiUKCNA/TNBOYUxFSOI/AAAAAAAAAr8/CQ38vHXaIxI/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA.png](http://lh3.ggpht.com/_VQNegiUKCNA/TNBOYUxFSOI/AAAAAAAAAr8/CQ38vHXaIxI/s640/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA.png)

> ### Патч для экспорта номеров карточек в CSV и печати в MS Access ###
![http://lh4.ggpht.com/_VQNegiUKCNA/TMwkwCrfYTI/AAAAAAAAArk/qDZ0LivON9c/screenshot.png](http://lh4.ggpht.com/_VQNegiUKCNA/TMwkwCrfYTI/AAAAAAAAArk/qDZ0LivON9c/screenshot.png)