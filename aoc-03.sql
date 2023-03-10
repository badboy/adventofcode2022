CREATE TABLE data(raw);
.import input03.txt data

WITH
RECURSIVE chars AS (
  SELECT rowid as id, raw, 0 AS i, "" AS c, 0 AS value FROM data
  UNION ALL
  SELECT
    id,
    raw,
    (i + 1) AS i,
    SUBSTR(raw, i+1, 1) AS c,
    CASE
      WHEN UNICODE(SUBSTR(raw, i+1, 1)) > 96 THEN UNICODE(SUBSTR(raw, i+1, 1))-96 -- lower
      ELSE UNICODE(SUBSTR(raw, i+1, 1))-64+26 -- uper
    END AS value
  FROM chars
  WHERE i < LENGTH(raw)
),
length AS (
  SELECT rowid as id, LENGTH(raw) AS length FROM data
),
halfs AS (
  SELECT
    id,
    raw,
    i,
    c,
    value,
    (i > length/2) AS side
  FROM
    chars INNER JOIN length USING (id)
  WHERE
    i > 0
),
double AS (
  SELECT
    h1.id,
    h1.raw,
    h1.c,
    h1.value
  FROM halfs h1 INNER JOIN halfs h2 ON (
    h1.id = h2.id
    AND h1.side = 0
    AND h2.side = 1
    AND h1.c = h2.c
  )
  WHERE h1.side = 0
  GROUP BY 1
),
groups_of_three AS (
  SELECT
    *,
    (id-1) / 3 AS cat
  FROM halfs
),
double_from_three AS (
  SELECT
    h1.id AS h1id,
    h2.id AS h2id,
    h2.c,
    h1.value,
    h1.cat
  FROM groups_of_three h1 JOIN groups_of_three h2 ON (
    h1.id != h2.id
    AND h1.cat = h2.cat
    AND h1.c = h2.c
  )
),
triple_from_three AS (
  SELECT
    g1.cat,
    g1.c,
    g1.value
  FROM double_from_three g1 JOIN double_from_three g2 ON (
    g1.h1id != g2.h2id
    AND g1.h2id = g2.h1id
    AND g1.c = g2.c
  )
  GROUP BY 1
)

-- SELECT * FROM double;
-- SELECT SUM(value) AS sum FROM double;
SELECT SUM(value) AS sum FROM triple_from_three
