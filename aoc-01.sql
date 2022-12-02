CREATE TABLE data(raw);
.import input01.txt data
WITH
groups AS (
  SELECT rowid, ROW_NUMBER() OVER (ORDER BY rowid) cat FROM data WHERE raw = ''
),
elves AS (
  SELECT
    COALESCE(
      (SELECT cat FROM groups WHERE data.rowid < groups.rowid LIMIT 1),
      (SELECT cat + 1 FROM groups ORDER BY cat DESC LIMIT 1)
    ) AS elf,
    raw as calories
  FROM data WHERE raw != ''
),
part1 AS (
  SELECT
    elf,
    SUM(calories) AS total_calories
  FROM elves
  GROUP BY 1
  ORDER BY 2 DESC
)

--SELECT * FROM part1;
SELECT SUM(total_calories) as best_3 FROM (
    SELECT * FROM part1 LIMIT 3
);
