


SCRIPTS_DIR=$PWD/scripts

mkdir $SCRIPTS_DIR

echo "DO
\$\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_database
        WHERE datname = 'northwind'
    ) THEN
        EXECUTE 'CREATE DATABASE northwind';
    END IF;
END
\$\$;" > $SCRIPTS_DIR/0-northwind_db.sql
# echo "CREATE TYPE order_status AS ENUM ('pending', 'shipped');"                                  >>    $SCRIPTS_DIR/01-northwind_dwh.sql
curl https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_ddl.sql     -Lo    $SCRIPTS_DIR/1-northwind_ddl.sql
curl https://raw.githubusercontent.com/yugabyte/yugabyte-db/master/sample/northwind_data.sql    -Lo    $SCRIPTS_DIR/2-northwind_data.sql
docker compose up -d 

python -m venv dbt-env 
. dbt-env/bin/activate 

pip install -r requirements.txt