# Лабораторная работа: Сравнение TOAST стратегий с типом данных VARCHAR

## Введение

TOAST (The Oversized-Attribute Storage Technique) — это метод хранения больших значений в PostgreSQL, используемый для сокращения объема данных, которые нужно хранить на диске. TOAST позволяет сжимать и/или хранить большие значения вне основной таблицы, чтобы уменьшить размер строки, которая должна умещаться на одной странице (8KB).

### Стратегии TOAST:

- **PLAIN**: Не допускает ни сжатия, ни отдельного хранения. Это единственно возможная стратегия для столбцов типов данных, которые несовместимы с TOAST.
- **EXTENDED**: Допускает как сжатие, так и отдельное хранение. Это стандартный вариант для большинства типов данных, совместимых с TOAST. Сначала происходит попытка выполнить сжатие, затем — сохранение вне таблицы, если строка всё ещё слишком велика.
- **EXTERNAL**: Допускает отдельное хранение, но не сжатие. Использование EXTERNAL ускорит операции над частями строк в больших столбцах `text` и `bytea` (ценой увеличения объёма памяти для хранения), так как эти операции оптимизированы для извлечения только требуемых частей отделённого значения, когда оно не сжато.
- **MAIN**: Допускает сжатие, но не отдельное хранение. (Фактически для таких столбцов будет тем не менее применяться отдельное хранение, но лишь как крайняя мера, когда нет другого способа уменьшить строку так, чтобы она помещалась на странице.)

## Создание таблиц с каждой стратегией

```pgsql
-- Таблица с TOAST стратегией PLAIN
CREATE TABLE toast_plain (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR
);
ALTER TABLE toast_plain ALTER COLUMN name SET STORAGE PLAIN;
```

```pgsql
-- Таблица с TOAST стратегией EXTERNAL
CREATE TABLE toast_external (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR
);
ALTER TABLE toast_external ALTER COLUMN name SET STORAGE EXTERNAL;
```

```pgsql
-- Таблица с TOAST стратегией EXTENDED (по умолчанию)
CREATE TABLE toast_extended (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR
);
```

```pgsql
-- Таблица с TOAST стратегией MAIN
CREATE TABLE toast_main (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR
);
ALTER TABLE toast_main ALTER COLUMN name SET STORAGE MAIN;
```

## Заполнение таблиц данными, которые больше 3Кб

```pgsql
-- Генерация данных для всех таблиц
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO toast_plain (ID, NAME) VALUES (i, repeat(md5(random()::text), 200));
        INSERT INTO toast_external (ID, NAME) VALUES (i, repeat(md5(random()::text), 200));
        INSERT INTO toast_extended (ID, NAME) VALUES (i, repeat(md5(random()::text), 200));
        INSERT INTO toast_main (ID, NAME) VALUES (i, repeat(md5(random()::text), 200));
    END LOOP;
END;
$$;
```

## Получение информации о размерах таблиц и TOAST таблиц
```pgsql
-- Получаем размеры таблицы и соответствующей TOAST таблицы
SELECT
    c.relname AS table_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    pg_size_pretty(pg_total_relation_size(c.reltoastrelid::regclass::text)) AS toast_size
FROM
    pg_class c
WHERE
    c.relname IN ('toast_plain', 'toast_external', 'toast_extended', 'toast_main');
```
Этот запрос используется для получения размеров как основной таблицы, так и связанной с ней TOAST таблицы.

Пояснение:

- `pg_total_relation_size(c.oid)`: Возвращает полный размер указанной таблицы, включая все связанные индексы и TOAST таблицы.
- `pg_total_relation_size(c.reltoastrelid::regclass::text)`: Возвращает размер только TOAST таблицы, связанной с основной таблицей.
- `pg_size_pretty()`: Форматирует размер таблицы в удобочитаемый вид (например, MB, GB).

Таким образом, этот запрос позволяет увидеть и сравнить размеры оригинальных таблиц и их TOAST таблиц, что является важным для оценки эффективности различных TOAST стратегий.

![Table_size](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/TOAST/HW%232%20-%20TOAST/imgs%20RESULT/result_original_siza_and_toast_size.png)

## TPS тесты

### Скрипт для тестирования

```pgsql
\set random_id random(1, 100)
SELECT name FROM :table WHERE id = :random_id;
```
Этот скрипт используется для тестирования производительности (TPS - Transactions Per Second) с помощью pgbench.

Пояснение:

- `\set random_id random(1, 100)`: Генерирует случайное значение random_id в диапазоне от 1 до 100 для каждой транзакции.
- `SELECT name FROM :table WHERE id = :random_id;`: Выполняет выборку строки из таблицы по случайному id.

### Команда для тестирования в pgbench

```bash
pgbench -U <имя_пользователя> -h <хост> -p <порт> -d <название базы данных> -n -c <количество_параллельных_клиентов> -T <время_выполнения_теста> -D table=<название_таблицы> -f <путь_к_файлу_скрипта>
```

> **Примечание:**  
флаг `-n` отключает выполнение команд VACUUM и ANALYZE перед тестом.  
`-D table=<название_таблицы>`: Указывает переменную table, которая будет использована в скрипте тестирования (`test_script.sql`), например `toast_plain`.

Я использовал такие параметры:  
`-c 1` (клиент);  
`-T 60` (секунд).

### Результаты

![toast_plain](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/TOAST/HW%232%20-%20TOAST/imgs%20RESULT/toast_plain.png)  
TOAST PLAIN

![toast_main](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/TOAST/HW%232%20-%20TOAST/imgs%20RESULT/toast_main.png)  
TOAST MAIN

![toast_external](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/TOAST/HW%232%20-%20TOAST/imgs%20RESULT/toast_external.png)  
TOAST EXTERNAL

![toast_extended](https://github.com/eto-uje-istoria/adv.-PostgreSQL/blob/TOAST/HW%232%20-%20TOAST/imgs%20RESULT/toast_extended.png)  
TOAST EXTENDED

## Вывод

Из результатов выше можно сделать следующие выводы:

- Стратегия **PLAIN** показала наивысший TPS, что логично, так как она не использует сжатие или отдельное хранение.
- Стратегия **MAIN** показала TPS ниже, чем PLAIN, но выше, чем EXTERNAL и EXTENDED.
- Стратегия **EXTERNAL** имеет наименьший TPS, так как отдельное хранение замедляет операции выборки.
- Стратегия **EXTENDED** показала средние результаты, так как она использует как сжатие, так и отдельное хранение.

Однако, важно отметить, что TPS может меняться в зависимости от данных и машин, на которых тестируются стратегии.
