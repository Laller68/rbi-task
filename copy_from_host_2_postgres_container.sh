docker cp northwind_db.sql postgres:/docker-entrypoint-initdb.d/northwind_db.sql
docker cp create_northwind_db.sql postgres:/docker-entrypoint-initdb.d/create_northwind_db.sql