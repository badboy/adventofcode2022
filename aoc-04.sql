CREATE TABLE data(raw);
.import input04.txt data

CREATE TABLE split_minmax (id, left, right, left_min, left_max, right_min, right_max);
CREATE TABLE part1 (id, left, right, contained);
CREATE TABLE part2 (id, left, right, contained);

WITH split AS (
  SELECT
    rowid as id,
    SUBSTR(raw, 1, INSTR(raw, ',')-1) AS left,
    SUBSTR(raw, INSTR(raw, ',')+1) AS right
  FROM data
)
INSERT INTO split_minmax
  SELECT
    *,
    CAST(SUBSTR(left, 1, INSTR(left, '-')-1) AS int) AS left_min,
    CAST(SUBSTR(left, INSTR(left, '-')+1) AS int) AS left_max,
    CAST(SUBSTR(right, 1, INSTR(right, '-')-1) AS int) AS right_min,
    CAST(SUBSTR(right, INSTR(right, '-')+1) AS int) AS right_max
  FROM split
;

INSERT INTO part1
  SELECT
    id, left, right,
    (
      (left_min <= right_min AND left_max >= right_max)
      OR (right_min <= left_min AND right_max >= left_max)
    ) AS contained
  FROM split_minmax
;
SELECT COUNT(*) AS solution1 FROM part1 WHERE contained = 1;

INSERT INTO part2
  SELECT
    id, left, right,
    (
      (left_min <= right_min AND left_max >= right_min)
      OR (right_min <= left_min AND right_max >= left_min)
    ) AS contained
  FROM split_minmax
;
SELECT COUNT(*) AS solution2 FROM part2 WHERE contained = 1;
