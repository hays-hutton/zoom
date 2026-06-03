-- Shape, not storage. This DDL declares the data shape of the four-column
-- contract; it is NOT a commitment to SQLite or any database. Runtime
-- representation is implementation-defined: choose whatever fits the target
-- language and the consumer's chosen Store. The Store interface in
-- commonsformat.md is the only persistence contract.

CREATE TABLE entries (
  document_id TEXT NOT NULL,
  pyramid_id  TEXT NOT NULL,
  level       INTEGER NOT NULL,
  key         TEXT NOT NULL
);

CREATE INDEX entries_by_level ON entries (level);
CREATE INDEX entries_by_pyramid ON entries (pyramid_id);
