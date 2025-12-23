#!/bin/bash
sudo apt update
sudo apt install -y postgresql

DB_NAME=sphinx
DB_USER=manager
DB_PASS=manager

sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD $DB_PASS;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\c speech
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  status TEXT,
  language TEXT,
  result TEXT
);
EOF
