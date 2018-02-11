#!/bin/bash

# Creates a bunch of tables in a MySQL instance.
#
# The whole purpose of this script is to exercise
# the part of the mysqld code that grabs a lock for
# each table that gets created.
#
# In a multitenant scenario where someone might be
# putting a bunch of mysql databases under a single
# EFS target, this becomes a problem - the quota will
# make the MySQL instances fail when it reaches it.

set -o errexit

# main routine that calls the
# table creation method N times
main() {
  local number_of_tables="$1"

  if [[ -z "$number_of_tables" ]]; then
    echo "ERROR:
  An argument (number of tables) must be supplied.
    "
    exit 1
  fi

  for i in $(seq 1 $number_of_tables); do
    create_table mytable$i
  done
}

# execute a command within the mysql
# container to create a table.
# args:
#       1) name of the table
create_table() {
  local name=$1

  echo "CREATE TABLE $name (
        id INT,
        data VARCHAR(100)
);" | docker exec -i inst1 \
    mysql --database=testdb
}

main
