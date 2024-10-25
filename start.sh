


SCRIPTS_DIR=$PWD/scripts

mkdir $SCRIPTS_DIR

echo "CREATE DATABASE IF NOT EXISTS northwind;"                                                  >>    $SCRIPTS_DIR/0-northwind_db.sql
curl https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_ddl.sql     -Lo    $SCRIPTS_DIR/1-northwind_ddl.sql
curl https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_data.sql    -Lo    $SCRIPTS_DIR/2-northwind_data.sql

docker compose up -d 

python -m venv dbt-env 
. dbt-env/bin/activate 

pip install -r requirements.txt