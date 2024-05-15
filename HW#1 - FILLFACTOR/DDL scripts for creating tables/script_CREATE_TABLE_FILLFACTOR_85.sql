CREATE TABLE table_fillfactor_85 (
    id SERIAL PRIMARY KEY,
    string_column VARCHAR(64)
) WITH (FILLFACTOR = 85);