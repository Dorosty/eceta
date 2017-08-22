for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" dombak` ; do  psql -c "alter table \"$tbl\" owner to dombak" dombak ; done
