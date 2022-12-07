--CREATE TABLE filesystem (
--  path,
--  type, -- 'd' or 'f'
--  size, -- 0 for dir
--);

-- SELECT * FROM fs ORDER BY path, id;

DELETE FROM nodes;
INSERT INTO nodes
  SELECT json_object('id', id, 'path', path, 'type', type)
  FROM fs;
-- SELECT * FROM nodes;

DELETE FROM edges;
INSERT INTO edges
  SELECT
    parent AS id,
    id AS target,
    json_object() AS properties
  FROM fs;
-- SELECT * FROM edges;

WITH RECURSIVE traverse(x, dir, y, obj) AS (
  SELECT id, path AS dir, '()', '{}' FROM fs WHERE type = 'd'
  UNION
  SELECT id, dir, '()', body FROM nodes JOIN traverse ON id = x
  UNION
  SELECT target, dir, '->', properties FROM edges JOIN traverse ON source = x
), dir AS (
  SELECT
    x, dir, obj->>'path' AS path
  FROM traverse
  WHERE
    y = '()'
    AND obj != '{}'
    AND dir != ''
), grouped_dir AS (
  SELECT
    dir,
    sum(size) AS size
  FROM dir LEFT JOIN fs ON fs.path = dir.path
  GROUP BY dir
  ORDER BY dir
)

SELECT
  sum(size) as size
FROM grouped_dir
WHERE size < 100000
