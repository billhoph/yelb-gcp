#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE yelbdatabase;
    \connect yelbdatabase;
	CREATE TABLE restaurants (
    	name        char(30),
    	count       integer,
    	PRIMARY KEY (name)
	);
	INSERT INTO restaurants (name, count) VALUES ('strata', 0);
	INSERT INTO restaurants (name, count) VALUES ('everything', 0);
	INSERT INTO restaurants (name, count) VALUES ('cortex', 0);
	INSERT INTO restaurants (name, count) VALUES ('prisma', 0);
EOSQL

