CREATE TABLE data(raw VARCHAR);
.import input08.txt data

-- x -> left-to-right
-- y -> top-to-bottom
CREATE TABLE forest (raw VARCHAR, x INTEGER, y INTEGER, c INTEGER);

-- not the border
CREATE TEMP VIEW inner_forest AS
  SELECT * from forest WHERE
    x > 1
    AND y > 1
    AND x < (SELECT MAX(x) FROM forest)
    AND y < (SELECT MAX(y) FROM forest);

-- how many trees on the outside?
CREATE TEMP VIEW border_tree_count AS
  SELECT
    MAX(x) * 2 + MAX(y) * 2 - 4 AS count
  FROM forest;

WITH
RECURSIVE chars AS (
  SELECT raw, 0 AS x, rowid as y, '' AS c FROM data
  UNION ALL
  SELECT
    raw,
    (x + 1) AS x,
    y,
    CAST(SUBSTR(raw, x+1, 1) AS INT) AS c
  FROM chars
  WHERE x < LENGTH(raw)
)
INSERT INTO forest SELECT * FROM chars WHERE x > 0;

WITH from_right AS (
  SELECT
    x, y, c
  FROM inner_forest f
  WHERE f.c > (
    SELECT MAX(i.c) FROM forest i WHERE i.y = f.y AND i.x > f.x
  )
)
, from_left AS (
  SELECT
    x, y, c
  FROM inner_forest f
  WHERE f.c > (
    SELECT MAX(i.c) FROM forest i WHERE i.y = f.y AND i.x < f.x
  )
)
, from_top AS (
  SELECT
    x, y, c
  FROM inner_forest f
  WHERE f.c > (
    SELECT MAX(i.c) FROM forest i WHERE i.y < f.y AND i.x = f.x
  )
)
, from_bottom AS (
  SELECT
    x, y, c
  FROM inner_forest f
  WHERE f.c > (
    SELECT MAX(i.c) FROM forest i WHERE i.y > f.y AND i.x = f.x
  )
)
, visible_inner AS (
  SELECT * FROM from_right
  UNION
  SELECT * FROM from_left
  UNION
  SELECT * FROM from_top
  UNION
  SELECT * FROM from_bottom
)

SELECT COUNT(*) + (SELECT count FROM border_tree_count LIMIT 1) AS total_visible FROM visible_inner
