for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" dombak` ; do  psql -c "alter table \"$tbl\" owner to dombak" dombak ; done
