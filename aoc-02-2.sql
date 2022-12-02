CREATE TABLE data(raw);
.import input02.txt data
WITH
moves AS (
  SELECT
    rowid AS round,
    SUBSTR(raw, 1, 1) AS other,
    SUBSTR(raw, 3, 3) AS self
  FROM data
),
shapescore (item, score) AS (
  VALUES
    ('X', 1),
    ('Y', 2),
    ('Z', 3)
),
points (other, self, score) AS (
  VALUES
    -- draw
    ('A', 'X', 3), -- rock rock
    ('B', 'Y', 3), -- paper paper
    ('C', 'Z', 3), -- scissors scissors
    -- wins
    ('A', 'Y', 6), -- rock paper
    ('B', 'Z', 6), -- paper scissors
    ('C', 'X', 6), -- scissors rock
    -- losses
    ('A', 'Z', 0), -- rock scissors
    ('B', 'X', 0), -- paper rock
    ('C', 'Y', 0)  -- scissors paper
), needtopick(other, outcome, self) AS (
    VALUES
    ('A', 'Y', 'X'),
    ('B', 'Y', 'Y'),
    ('C', 'Y', 'Z'),

    ('A', 'Z', 'Y'),
    ('A', 'X', 'Z'),
    ('B', 'Z', 'Z'),

    ('B', 'X', 'X'),
    ('C', 'Z', 'X'),
    ('C', 'X', 'Y')
), game AS (
  SELECT
    round,
    other,
    moves.self as outcome,
    (SELECT n.self FROM needtopick n WHERE n.other = moves.other AND n.outcome = moves.self) AS self
  FROM moves
), game1 AS (
  SELECT
    round,
    other,
    self,
    outcome,
    (SELECT s.score FROM shapescore s WHERE item = self) AS s_score,
    (SELECT p.score FROM points p WHERE p.other = game.other AND p.self = game.self) AS points
  FROM game
), game_with_total AS (
  SELECT
    *,
    s_score + points AS score
  FROM game1
)

SELECT SUM(score) as score FROM game_with_total;
