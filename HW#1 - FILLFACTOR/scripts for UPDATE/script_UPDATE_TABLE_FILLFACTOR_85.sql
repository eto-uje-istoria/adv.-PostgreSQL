\SET random_id random(1, 1000000)
UPDATE table_fillfactor_85
SET string_column = md5(random()::text)
WHERE id = :random_id