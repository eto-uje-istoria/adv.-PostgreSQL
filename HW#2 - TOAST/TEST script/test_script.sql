\set random_id random(1, 100)
SELECT name FROM :table WHERE id = :random_id;
