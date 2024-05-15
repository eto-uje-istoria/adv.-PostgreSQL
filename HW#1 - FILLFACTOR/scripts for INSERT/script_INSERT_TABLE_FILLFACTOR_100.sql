INSERT INTO table_fillfactor_100 (string_column)
SELECT md5(random()::text)
FROM generate_series(1, 1000000);