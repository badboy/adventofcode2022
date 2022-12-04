CREATE TABLE data(raw);
.import input04.txt data

CREATE TABLE split_rows (id, sections, pos, min, max);

WITH split AS (
  SELECT
    rowid as id,
    SUBSTR(raw, 1, INSTR(raw, ',')-1) AS left,
    SUBSTR(raw, INSTR(raw, ',')+1) AS right
  FROM data
), split_minmax AS (
  SELECT
    *,
    CAST(SUBSTR(left, 1, INSTR(left, '-')-1) AS int) AS left_min,
    CAST(SUBSTR(left, INSTR(left, '-')+1) AS int) AS left_max,
    CAST(SUBSTR(right, 1, INSTR(right, '-')-1) AS int) AS right_min,
    CAST(SUBSTR(right, INSTR(right, '-')+1) AS int) AS right_max
  FROM split
), is_contained AS (
  SELECT
    *,
    (
      (left_min <= right_min AND left_max >= right_max)
      OR (right_min <= left_min AND right_max >= left_max)
    ) AS contained
  FROM split_minmax
)

SELECT COUNT(*) FROM is_contained WHERE contained = 1;
