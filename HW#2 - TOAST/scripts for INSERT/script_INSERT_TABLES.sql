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
