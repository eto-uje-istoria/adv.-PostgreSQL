-- Получаем размеры таблицы и соответствующей TOAST таблицы
SELECT
    c.relname AS table_name,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    pg_size_pretty(pg_total_relation_size(t.reltoastrelid::regclass)) AS toast_size
FROM
    pg_class c
JOIN
    pg_class t ON c.oid = t.oid
WHERE
    c.relname IN ('toast_plain', 'toast_external', 'toast_extended', 'toast_main');