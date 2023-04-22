### Deployment of the Postgres DB poller and Postgres monitoring 

**Task:**

I choose the docker-compose deployment with helps of Docker environment

Github repository (pubkic): https://github.com/Laller68/rbi-task


### Introduction

Docker is a popular containerization technology that allows you to create, deploy, and run applications in a containerized environment. Postgres is a powerful open-source database management system that is widely used in many applications. By combining these two technologies, you can easily deploy Postgres in a containerized environment using Docker.

This document will guide you through the process of deploying Postgres in Docker and loading the northwind_db.sql on initial boot.



### Prerequisites

- Docker engine 

- Docker Compose 

### Deployment Steps

1. Create a new directory for the deployment and copy the compose file into it.

2. Open a terminal or command prompt and navigate to the deployment directory.

3. Run the following command to start the services:

```bash
docker-compose up -d
```
This will download the required images, create and start the containers in detached mode.

4. Wait a few minutes for all services to start up and become ready.

5. Access the services through their respective web interfaces:

- Postgres: http://localhost:5432
- PgAdmin4: http://localhost:5050
- Pgbouncer: http://localhost:6432
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000


**Step 1: Create a Docker Compose file**

Create a new file named *docker-compose.yaml* and add the following content:

![alt text for screen readers](/images/portainer_1.png "portainer_rbi_stack")

## Docker Compose with the following steps:

1. Create a new folder for the project.
2. Create a **docker-compose.yaml** file in the root directory of the folder. 
3. Configure the docker-compose.yaml file as follows:

## Postgres Docker image creation

1. Pulling the original **postgres** imangeg from DockerHub
2. Splitting the original notthwind_db.sql file into two parts. a.) create_northwind_db.sql b.) northwind_db.sql

```bash
      - ./create_northwind_db.sql:/docker-entrypoint-initdb.d/create_northwind_db.sql
      - ./northwind_db.sql:/docker-entrypoint-initdb.d/northwind_db.sql
```

3. Copy the sql srcipt into the host directory from the original source **harryho/db-samples** https://github.com/harryho/db-samples/blob/master/pgsql/northwind.sql
4. Copy the file(s) into the **postgres** image

```bash
docker cp northwind_db.sql postgres:/docker-entrypoint-initdb.d/northwind_db.sql
docker cp create_northwind_db.sql postgres:/docker-entrypoint-initdb.d/create_northwind_db.sql
```

### Why in docker-entrypoint-initdb.d/ ?###

a.) The official PostgreSQL Docker image https://hub.docker.com/_/postgres/ allows us to place SQL files in the /docker-entrypoint-initb.d folder, and the first time the service starts, it will import and execute those SQL files.

![alt text for screen readers](/images/postgres_container.png "postgres_container")

b.) In our Postgres container, we will find this bash script /usr/local/bin/docker-entrypoint.sh where each *.sh, **.sql and *.*sql.gz file will be executed.

```bash
      - ./create_northwind_db.sql:/docker-entrypoint-initdb.d/create_northwind_db.sql
      - ./northwind_db.sql:/docker-entrypoint-initdb.d/northwind_db.sql
```

### PgBouncer Docker container configuration

PgBouncer is a lightweight connection pooler for PostgreSQL that sits between the application and the database. It allows multiple clients to share a single connection to the database, reducing the number of connections and improving performance.

In the provided configuration, the following parameters are defined:

**image:** specifies the Docker image to be used for the PgBouncer container, which is pgbouncer/pgbouncer.

**container_name:** sets the name of the Docker container that will be created for PgBouncer, which is pgbouncer.

**restart:** specifies that the PgBouncer container should be restarted automatically if it stops unexpectedly.

**depends_on:** indicates that the PgBouncer container depends on the postgresdb container being started first.

**environment:** sets various environment variables for the PgBouncer container, including:

**PGBOUNCER_AUTH_USER:** specifies the username that PgBouncer will use to authenticate with the database.

**PGBOUNCER_AUTH_PASSWORD:** sets the password for the PgBouncer user.

**PGBOUNCER_DEFAULT_POOL_SIZE:** sets the default number of connections in the connection pool.

**PGBOUNCER_MAX_CLIENT_CONN:** specifies the maximum number of client connections that can be made to the database at once.

**PGBOUNCER_POOL_MODE:** sets the pool mode, which is session in this case, meaning that each client will get its own session with the database.

**PGBOUNCER_POOL_SIZE:** sets the maximum number of connections that can be in the pool at any given time.

**PGBOUNCER_SERVER_IDLE_TIMEOUT:** sets the amount of time (in seconds) that a server can be idle before it is closed.

**PGBOUNCER_SERVER_IDLE_TRANSACTION_TIMEOUT:** sets the amount of time (in seconds) that a transaction can be idle before it is rolled back.

**PGBOUNCER_SERVER_ROUND_ROBIN:** specifies whether servers are chosen in a round-robin fashion (1 means yes, 0 means no).

**PGBOUNCER_SERVERS:** specifies the address and port of the PostgreSQL server that PgBouncer should connect to.

**ports:** maps the container's 6432 port to the host machine's 6432 port, allowing connections to be made to PgBouncer from outside the Docker network.