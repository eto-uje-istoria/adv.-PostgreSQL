-- Таблица с TOAST стратегией PLAIN
CREATE TABLE toast_plain (
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR
);
ALTER TABLE toast_plain ALTER COLUMN name SET STORAGE PLAIN;
