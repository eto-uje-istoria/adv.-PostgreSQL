CREATE TABLE table_fillfactor_100 (
    id SERIAL PRIMARY KEY,
    string_column VARCHAR(64)
) WITH (FILLFACTOR = 100);