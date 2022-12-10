CREATE TABLE data(raw);
.import input10.txt data

CREATE TABLE ops(idx, op, reg INT);
INSERT INTO ops
  SELECT
    rowid as idx,
    SUBSTR(raw, 1, 4) AS op,
    CAST(SUBSTR(raw, 6) AS INT) AS reg
  FROM data;

CREATE TABLE mem(cycle INT, x INT);

WITH RECURSIVE run AS (
  SELECT
    0 AS idx,
    0 AS cycle,
    1 AS x,
    NULL AS op,
    NULL AS reg
  UNION
  SELECT
    run.idx + 1 AS idx,
    CASE
    WHEN ops.op = 'noop' THEN run.cycle+1
    WHEN ops.op = 'addx' THEN run.cycle+2
    END AS cycle,
    CASE
    WHEN ops.op = 'noop' THEN run.x
    WHEN ops.op = 'addx' THEN run.x + ops.reg
    END AS x,
    ops.op,
    ops.reg
  FROM run LEFT JOIN ops ON ops.idx = run.idx+1

  LIMIT (SELECT COUNT(*) FROM ops)+1
)
INSERT INTO mem SELECT cycle, x FROM run;

CREATE TABLE important_cycles (cycle);
INSERT INTO important_cycles VALUES
  (20),
  (60),
  (100),
  (140),
  (180),
  (220);

WITH results AS (
  SELECT
    c.cycle,
    (SELECT x FROM mem WHERE mem.cycle < c.cycle ORDER BY rowid DESC LIMIT 1) AS x
  FROM important_cycles c
)

SELECT SUM(cycle * x) FROM results;
