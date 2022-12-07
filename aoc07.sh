#!/bin/bash

. .venv/bin/activate
rm -f aoc07.db
sqlite3 aoc07.db <<'EOF'
CREATE TABLE IF NOT EXISTS nodes (
    body TEXT,
    id   TEXT GENERATED ALWAYS AS (json_extract(body, '$.id')) VIRTUAL NOT NULL UNIQUE
);

CREATE INDEX IF NOT EXISTS id_idx ON nodes(id);

CREATE TABLE IF NOT EXISTS edges (
    source     TEXT,
    target     TEXT,
    properties TEXT,
    UNIQUE(source, target, properties) ON CONFLICT REPLACE,
    FOREIGN KEY(source) REFERENCES nodes(id),
    FOREIGN KEY(target) REFERENCES nodes(id)
);

CREATE INDEX IF NOT EXISTS source_idx ON edges(source);
CREATE INDEX IF NOT EXISTS target_idx ON edges(target);
EOF
sqlite-utils insert --silent aoc07.db fs input07.txt --text --convert '
lines = text.split("\n")
out = []
out.append({"id": abs("/".__hash__()), "path": "/", "type": "d", "size": 0, "parent": 0})
cwd = ""
id = 1
for line in lines:
  if len(line) == 0: continue
  if line[0] == "$":
    if line[2:4] == "cd":
      dir = line[5:]
      if dir == "/":
        cwd = "/"
      elif dir == "..":
        cwd =  "/".join(cwd.rsplit("/")[0:-2]) + "/"
      else:
        cwd += dir + "/"
      continue
    if line[2:4] == "ls":
      continue
  if line[0:3] == "dir":
    path = cwd + line[4:] + "/"
    thisid = abs(path.__hash__())
    out.append({"id": thisid, "path": path, "type": "d", "size": 0, "parent": abs(cwd.__hash__())})
  else:
    size, name = line.split()
    size = int(size)
    id += 1
    out.append({"id": id, "path": cwd + name, "type": "f", "size": size, "parent": abs(cwd.__hash__())})

return out
'
sqlite-utils dump aoc07.db
