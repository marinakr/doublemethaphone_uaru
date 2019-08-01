sql improved implementation of http://forum.aeroion.ru/topic461.html
```
mpi_dev=# select MetaPhoneUaRuLastName2('Михал''овская');
 metaphoneuarulastname2
------------------------
 МХЛ#
(1 row)

mpi_dev=# select MetaPhoneUaRuLastName2('Михалівска');
 metaphoneuarulastname2
------------------------
 МХЛ#
(1 row)

select MetaPhoneUaRuLastName2('шфорснігир') = MetaPhoneUaRuLastName2('шварценеггер');
 ?column?
----------
 t
(1 row)


select  MetaPhoneUaRuLastName2('швартсцсенеггер');
 metaphoneuarulastname2
------------------------
 ШФРСНКР
(1 row)

```
