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
