# Postgres

## List databases

```
\l

# to get more info, like size
\l+ 
```

## List users
```
\du

\du+
```

## list active connections

```
SELECT * FROM pg_stat_activity;

SELECT * FROM pg_stat_activity WHERE datname = 'dbname';

SELECT count(*) FROM pg_stat_activity;
```

## Create dumb data

```
CREATE DATABASE mvalgueiro;

\c mvalgueiro

CREATE TABLE distributors (
  did     integer CONSTRAINT no_null NOT NULL,
  name    varchar(40) NOT NULL
);

INSERT INTO distributors VALUES(2, 'cleber');

SELECT * FROM distributors;
```
