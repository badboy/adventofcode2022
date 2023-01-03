# Advent of Code 2022

> If all you have is data, everything looks like a `SELECT`.

My solutions to this year's [Advent of Code][AoC], done in SQL, incomplete.

I blogged about it: [SELECT solution FROM aoc WHERE year = 2022][blog].

## Requirements

* [SQLite]
* [sqlite-utils] (for day 7)
* The [`define` extension][define] from [SQLean] (for day 8)

## My own rules

* Solve it in SQL.
  * I started to run that in [BigQuery], but moved to [SQLite].
* Only the SQL the system provides. How far can I take this?
  * It was easier on BigQuery with its large base of functionality, including string procesing, arrays, structs, ...
  * On SQLite initially I tried to avoid any custom functionality, I later relaxed this rule: [SQLean] is okay occasionally.
  * Once (so far) I used Python to preprocess the data. SQL is just really not good at text processing.
* Getting the solution once is good enough.
  * The code can be ugly, messy and inefficient.
* I don't write tests.
  * I do test. Just manually against the test input.
* No persistent data.
  * It's all in-memory tables, CTEs, temporary views and a bunch of `SELECT`.
* Learn some arcane SQL features.
  * Did you know SQL can recurse and select over windows? I do now!

These are my rules. I break them when I feel like it.

## Run it

(Nearly) Every day should be runnable by:

```
sqlite3 < aoc-01.sql
```

[AoC]: https://adventofcode.com/2022
[blog]: https://fnordig.de/2022/12/09/select-solution-from-aoc-where-year-2022/
[BigQuery]: https://cloud.google.com/bigquery/
[SQLite]: https://sqlite.org/
[SQLean]: https://github.com/nalgeon/sqlean
[sqlite-utils]: https://sqlite-utils.datasette.io/
[define]: https://github.com/nalgeon/sqlean/blob/main/docs/define.md
