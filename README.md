# Лабораторная работа: Сравнение стратегий работы с параметром FILLFACTOR в PostgreSQL

## Введение

В PostgreSQL параметр FILLFACTOR определяет процент заполнения страницы индекса, что позволяет управлять фрагментацией данных и использованием дискового пространства. В данной лабораторной работе мы сравним различные стратегии работы с параметром FILLFACTOR и оценим их влияние на производительность базы данных.

## Описание эксперимента

### Создание таблиц

Были созданы три таблицы с одинаковой структурой модели данных, но с различным значением параметра FILLFACTOR: 85, 90 и 100. 

```pgsql
-- script_CREATE_TABLE_FILLFACTOR_85.sql
CREATE TABLE table_fillfactor_85 (
    id SERIAL PRIMARY KEY,
    string_column VARCHAR(64)
) WITH (FILLFACTOR = 85);
```

```pgsql
-- script_CREATE_TABLE_FILLFACTOR_90.sql
CREATE TABLE table_fillfactor_90 (
    id SERIAL PRIMARY KEY,
    string_column VARCHAR(64)
) WITH (FILLFACTOR = 90);
```

```pgsql
-- script_CREATE_TABLE_FILLFACTOR_100.sql
CREATE TABLE table_fillfactor_100 (
    id SERIAL PRIMARY KEY,
    string_column VARCHAR(64)
) WITH (FILLFACTOR = 100);
```

### Заполнение таблиц

Каждая таблица была заполнена 1 000 000 строками с помощью скриптов для генерации случайных данных.

```pgsql
-- script_INSERT_TABLE_FILLFACTOR_85.sql
INSERT INTO table_fillfactor_85 (string_column)
SELECT md5(random()::text)
FROM generate_series(1, 1000000);
```

```pgsql
-- script_INSERT_TABLE_FILLFACTOR_90.sql
INSERT INTO table_fillfactor_90 (string_column)
SELECT md5(random()::text)
FROM generate_series(1, 1000000);
```

```pgsql
-- script_INSERT_TABLE_FILLFACTOR_100.sql
INSERT INTO table_fillfactor_100 (string_column)
SELECT md5(random()::text)
FROM generate_series(1, 1000000);
```

### Обновление данных

Для каждой таблицы был создан скрипт для обновления значений в столбце с типом VARCHAR по ключу PK.

```pgsql
-- script_UPDATE_TABLE_FILLFACTOR_85.sql
\SET random_id random(1, 1000000)
UPDATE table_fillfactor_85
SET string_column = md5(random()::text)
WHERE id = :random_id;
```

```pgsql
-- script_UPDATE_TABLE_FILLFACTOR_90.sql
\SET random_id random(1, 1000000)
UPDATE table_fillfactor_90
SET string_column = md5(random()::text)
WHERE id = :random_id;
```

```pgsql
-- script_UPDATE_TABLE_FILLFACTOR_100.sql
\SET random_id random(1, 1000000)
UPDATE table_fillfactor_100
SET string_column = md5(random()::text)
WHERE id = :random_id;
```

> **Примечание:** В PostgreSQL CLI (`psql`) команда `\set` используется для определения переменных среды, которые могут использоваться в запросах. В примере `\set random_id random(1, 1000000)` мы создаем переменную `random_id`, которая будет хранить случайное число в диапазоне от 1 до 1 000 000.

### Тестирование обновления данных

Для тестирования обновления данных используйте следующую команду в консоли (`pgbench`):

```bash
pgbench -U <имя_пользователя> -h <хост> -p <порт> -d <название_базы_данных> -c <количество_параллельных_клиентов> -T <время_выполнения_теста> -f <путь_к_файлу_скрипта>
```

Я использовал такие параметры:  
`-c 1` (клиент);  
`-T 60` (секунд).

### Результаты

Были проведены измерения TPS метрик для нагрузочного скрипта по каждой таблице.

![TPS для таблицы с fillfactor = 85](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/FILLFACTOR/HW%231%20-%20FILLFACTOR/img%20RESULT/RESULT_FILLFACTOR_85.png)  
TPS = 53.2 для таблицы с FILLFACTOR 85  

![TPS для таблицы с fillfactor = 90](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/FILLFACTOR/HW%231%20-%20FILLFACTOR/img%20RESULT/RESULT_FILLFACTOR_90.png)  
TPS = 36.6 для таблицы с FILLFACTOR 90  

![TPS для таблицы с fillfactor = 100](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/FILLFACTOR/HW%231%20-%20FILLFACTOR/img%20RESULT/RESULT_FILLFACTOR_100.png)  
TPS = 33.1 для таблицы с FILLFACTOR 100  

### Вывод

Из полученных данных можно сделать вывод, что при определенных условиях уменьшение значения FILLFACTOR может привести к увеличению производительности за счет более эффективного использования доступного дискового пространства. Однако стоит помнить, что это может быть полезно только в определенных сценариях и требует тщательного анализа и тестирования для каждой конкретной ситуации.
