CREATE TABLE data(signal);
.import input06.txt data

CREATE TEMP TABLE grouped(
  id, signal, i, group_concat
);

WITH
RECURSIVE chars AS (
  SELECT rowid as id, signal, 0 AS i, "" AS c FROM data
  UNION ALL
  SELECT
    id,
    signal,
    (i + 1) AS i,
    SUBSTR(signal, i+1, 1) AS c
  FROM chars
  WHERE i < LENGTH(signal)
), signal AS (
SELECT * FROM chars WHERE i > 0
), grouped_data AS (
  SELECT
    id,
    signal,
    i,
    COUNT(c) OVER (
      ORDER BY i ROWS BETWEEN CURRENT ROW AND 13 FOLLOWING
    ) AS group_count,
    group_concat(c, '') OVER (
      ORDER BY i ROWS BETWEEN CURRENT ROW AND 13 FOLLOWING
    ) AS group_concat
  FROM signal
)
INSERT INTO grouped SELECT id, signal, i, group_concat FROM grouped_data WHERE group_count = 14;

WITH
RECURSIVE grouped_chars AS (
  SELECT id * 100 + i as id, id as old_id, group_concat, 0 AS cnt, "" AS c FROM grouped
  UNION ALL
  SELECT
    id,
    old_id,
    group_concat,
    (cnt + 1) AS cnt,
    SUBSTR(group_concat, cnt+1, 1) AS c
  FROM grouped_chars
  WHERE cnt < LENGTH(group_concat)
), grouped_counted AS (
  SELECT
    id,
    old_id,
    group_concat,
    COUNT(DISTINCT c) AS cnt
  FROM grouped_chars
  WHERE cnt > 0
  GROUP BY id, old_id, group_concat
)
SELECT *, id - (old_id*100) + 13 as marker FROM grouped_counted WHERE cnt = 14 ORDER BY id LIMIT 1
