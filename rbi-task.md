###Task: 

#### Automate the installation and setup of a PostgreSQL DB with PgBouncer as a connection pooler

1. Take an existent simple test DB, northwind (Northwind sample.), an example of how to create the
database can be found in the README

2. Configure PgBouncer to authenticate users against the DB and direct incoming requests to
PostgreSQL:

a) Configure PgBouncer so that username and password are authenticated against PostgreSQL

  environment:
      # AUTH_TYPE: md5
      # AUTH_FILE: /etc/pgbouncer/userlist.txt
      PGBOUNCER_AUTH_USER: **hho**
      PGBOUNCER_AUTH_PASSWORD: **northwind!pw**
      PGBOUNCER_DEFAULT_POOL_SIZE: 20
      PGBOUNCER_MAX_CLIENT_CONN: 100
      PGBOUNCER_POOL_MODE: session
      PGBOUNCER_POOL_SIZE: 20
      PGBOUNCER_SERVER_IDLE_TIMEOUT: 60
      PGBOUNCER_SERVER_IDLE_TRANSACTION_TIMEOUT: 300
      PGBOUNCER_SERVER_ROUND_ROBIN: 1
      PGBOUNCER_SERVERS: postgresdb:5432/Northwind


without completely relying on userlist.txt.
b) Client connections to the DB should go through PGBouncer

Create connection in PgAdmin using of the PGBouncer credentials

```bash
psql -h localhost -p 5432 -U hho Northwind
```
or

![alt text for screen readers](/images/connect_pgbouncer.png "postgres_container")

3. Installation and configuration of PostgreSQL and PGBouncer should be automated as well as the
creation of the database

4. There is no automation tooling restriction but below you can find a list of tools you can orient on:
a) Dockerfiles
b) Ansible
c) **Docker Compose**  -- please find **docker-compose.yml** file 

Expected Outcome
1. Justification for all tool decisions (e.g., Ansible because of...). 
2. You would be able to demo how the solution works
3. Document and present design, ideally with diagram
**4. All written Artefacts in a zip archive or on a github repository :** 
1. Build files
2. Dockerfiles
3. any other glue code in any possible script/shell/bash language  

To automate the installation and setup of a PostgreSQL DB with PgBouncer as a connection pooler and add the automatic database creation script to a Docker Compose file, I would do the following:

## Step 1: Create a new directory
Create a new directory for your project and navigate to it:

```bash
mkdir postgres-docker
cd postgres-docker
```
## Step 2: Create a Docker Compose file
Create a new file named docker-compose.yaml and add the following content:

* It is not a final expression!

```yaml
version: '3'

services:
  postgresdb:
    image: postgres_northwind:latest
    container_name: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data     
      - ./create_tables.sql:/docker-entrypoint-initdb.d/create_tables.sql
    restart: always
    environment:
      POSTGRES_USER: hho
      POSTGRES_PASSWORD: northwind!pw
      POSTGRES_DB: Northwind    
    
    ports:
      - 5432:5432  

volumes:
  postgres_data:

```  

## Step 3: Build the Docker image
In this step, we will create a custom Docker image that includes the northwind_db.sql file. First, download the northwind_db.sql file from here and save it to the same directory as the docker-compose.yaml file.

Next, create a new file named Dockerfile and add the following content:

### Dockerfile

```bash
FROM postgres:12
COPY ./northwind_db.sql /docker-entrypoint-initdb.d/
```

This Dockerfile is based on the official Postgres 12 Docker image and copies the northwind_db.sql file to the /docker-entrypoint-initdb.d/ directory in the container.

Now, build the Docker image using the following command:

```bash
docker build -t postgres_northwind .
```

## Step 4: Run the Docker container
Run the Postgres container using the following command:

```code
docker-compose up -d
```

This command will start the container in detached mode, which means it will run in the background.

## Step 5: Verify the container is running
Verify that the container is running by executing the following command:

```code
docker ps
```

This command will show a list of running containers, including the postgres container.

## Step 6: Connect to the Postgres database
To connect to the Postgres database, you can use a client such as psql. First, install psql on your system if you haven't already done so.

Next, connect to the database using the following command:

```code
psql -h localhost -p 5432 -U hho Northwind
```