CREATE TABLE data(raw);
.import input09.txt data

CREATE TABLE ops(idx, dir, steps INT);
INSERT INTO ops SELECT rowid as idx, SUBSTR(raw, 1, 1) AS dir, SUBSTR(raw, 3) AS steps FROM data;
-- SELECT * FROM ops;

CREATE TABLE expanded_ops(idx, dir, steps INT);
INSERT INTO expanded_ops
  SELECT
    row_number() OVER (ORDER BY idx) AS idx,
    dir,
    1 AS steps
  FROM ops, generate_series(1, steps) s;

-- SELECT * FROM expanded_ops;

CREATE TABLE head_states (iter INT, state INT, x INT, y INT, dir);
WITH RECURSIVE states AS (
  -- starting position
  SELECT 0 as iter, 0 AS state, 0 AS x, 0 AS y, NULL AS dir
  UNION ALL
  SELECT
    iter + 1 AS iter,
    ops.idx AS state,
    CASE
    WHEN ops.dir = 'R' THEN x + 1
    WHEN ops.dir = 'L' THEN x - 1
    ELSE x
    END AS x,
    CASE
    WHEN ops.dir = 'U' THEN y + 1
    WHEN ops.dir = 'D' THEN y - 1
    ELSE y
    END AS y,
    ops.dir
  FROM states LEFT JOIN expanded_ops ops ON ops.idx = states.iter + 1
  LIMIT (SELECT COUNT(*)+1 FROM expanded_ops)
)
INSERT INTO head_states SELECT * FROM states;

-- SELECT * FROM head_states;
-- SELECT COUNT(*) FROM head_states;

-- .headers off
-- .mode csv
WITH RECURSIVE tail_states AS (
  SELECT
    *,
    0 AS tail_x,
    0 AS tail_y,
    NULL AS prev_dir
  FROM head_states
  WHERE iter = 0
  UNION ALL
  SELECT
    h.iter,
    h.state,
    h.x,
    h.y,
    h.dir,
    CASE
    -- moved in x direction
    WHEN h.dir = 'R' AND h.x > states.tail_x+1 THEN states.tail_x + 1
    WHEN h.dir = 'L' AND h.x < states.tail_x-1 THEN states.tail_x - 1
    -- moved in y direction -> move diagonal
    WHEN h.dir = 'U' AND h.x > states.tail_x AND h.y > states.tail_y+1 THEN states.tail_x + 1
    WHEN h.dir = 'U' AND h.x < states.tail_x AND h.y > states.tail_y+1 THEN states.tail_x - 1

    WHEN h.dir = 'D' AND h.x > states.tail_x AND h.y < states.tail_y-1 THEN states.tail_x + 1
    WHEN h.dir = 'D' AND h.x < states.tail_x AND h.y < states.tail_y-1 THEN states.tail_x - 1
    ELSE states.tail_x
    END as tail_x,
    CASE
    -- moved in y direction
    WHEN h.dir = 'U' AND h.y > states.tail_y+1 THEN states.tail_y + 1
    WHEN h.dir = 'D' AND h.y < states.tail_y-1 THEN states.tail_y - 1
    -- moved in x direction -> move diagonal
    WHEN h.dir = 'R' AND h.y > states.tail_y AND h.x > states.tail_x+1 THEN states.tail_y + 1
    WHEN h.dir = 'R' AND h.y < states.tail_y AND h.x > states.tail_x+1 THEN states.tail_y - 1

    WHEN h.dir = 'L' AND h.y > states.tail_y AND h.x < states.tail_x-1 THEN states.tail_y + 1
    WHEN h.dir = 'L' AND h.y < states.tail_y AND h.x < states.tail_x-1 THEN states.tail_y - 1
    ELSE states.tail_y
    END as tail_y,
    states.dir AS prev_dir
  FROM tail_states states LEFT JOIN head_states h ON h.iter = states.iter + 1

  LIMIT (SELECT COUNT(*) FROM head_states)
)

, tail_states_visited AS (
  SELECT tail_x, tail_y, COUNT(*) FROM tail_states GROUP BY tail_x, tail_y
)

-- SELECT iter,x,y,tail_x,tail_y,dir FROM tail_states LIMIT 10
-- SELECT * FROM tail_states LIMIT 12;
SELECT COUNT(*) FROM tail_states_visited;
