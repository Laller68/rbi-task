### Deployment of the Postgres DB pooler (PgBouncer) and Postgres DB monitoring 

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

```code
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

```yaml
      - ./create_northwind_db.sql:/docker-entrypoint-initdb.d/create_northwind_db.sql
      - ./northwind_db.sql:/docker-entrypoint-initdb.d/northwind_db.sql
```

3. Copy the sql srcipt into the host directory from the original source **harryho/db-samples** https://github.com/harryho/db-samples/blob/master/pgsql/northwind.sql
4. Copy the file(s) into the **postgres** image

```code
docker cp northwind_db.sql postgres:/docker-entrypoint-initdb.d/northwind_db.sql
docker cp create_northwind_db.sql postgres:/docker-entrypoint-initdb.d/create_northwind_db.sql
```

### Why in docker-entrypoint-initdb.d/ ?###

a.) The official PostgreSQL Docker image https://hub.docker.com/_/postgres/ allows us to place SQL files in the /docker-entrypoint-initb.d folder, and the first time the service starts, it will import and execute those SQL files.

![alt text for screen readers](/images/postgres_container.png "postgres_container")

b.) In our Postgres container, we will find this bash script /usr/local/bin/docker-entrypoint.sh where each *.sh, **.sql and *.*sql.gz file will be executed.

```code
      - ./create_northwind_db.sql:/docker-entrypoint-initdb.d/create_northwind_db.sql
      - ./northwind_db.sql:/docker-entrypoint-initdb.d/northwind_db.sql
```

### PgBouncer Docker container configuration

PgBouncer is a lightweight connection pooler for PostgreSQL that sits between the application and the database. It allows multiple clients to share a single connection to the database, reducing the number of connections and improving performance.


![alt text for screen readers](/images/pgbouncer_intro.png "postgres_container")

The pgbouncer.ini file is a configuration file for the PgBouncer connection pooler, which acts as a middleman between the client and the PostgreSQL database. It contains various settings that define how PgBouncer operates, including database connection parameters, authentication settings, and pool configuration.

Here are some common parameters found in a pgbouncer.ini file:

**listen_addr and listen_port:** Specifies the address and port that PgBouncer listens on for incoming connections.

**auth_type and auth_file:** Specifies the type of authentication used and the file containing the list of authorized users and passwords.

**pool_mode and pool_size:** Specifies the pooling mode and maximum number of connections in the pool for each database.

**server_round_robin:** Specifies whether PgBouncer distributes connections across servers in a round-robin fashion.

server_idle_timeout and **server_idle_transaction_timeout:** Specifies how long idle connections and transactions are kept alive before being closed.

**client_idle_timeout** and **client_login_timeout:** Specifies how long idle clients and login attempts are kept alive before being disconnected.

Overall, the **pgbouncer.ini** file is an important configuration file that allows you to customize the behavior of PgBouncer according to your needs.

![alt text for screen readers](/images/pgbouncer_advanced.png "postgres_container")

### Docker-compose configuration (PgBouncer) 

In the provided configuration will setup using of Docker init environmetal variables, the following parameters are defined:

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

**ports:** maps the container's **6432** port to the host machine's 6432 port, allowing connections to be made to **PgBouncer** from outside the Docker network.

### Prometheus, Grafana, Cadvisor as well as Postgres-exporter stack for Postgres monitoring

**Prometheus** is an open-source monitoring system that collects and stores metrics data from different systems and applications. It uses a pull-based model to scrape and collect metrics data, which makes it highly scalable and efficient. Prometheus provides a query language, **PromQL**, for querying and analyzing metrics data, and it can send alerts when certain conditions are met.

![alt text for screen readers](/images/prometheus_ui.png "postgres_container")

**Grafana** is an open-source data visualization and monitoring tool that can be used with Prometheus and other data sources. It allows users to create and customize dashboards to display metrics data in a variety of ways, such as graphs, charts, and tables. Grafana also supports alerting, so users can receive notifications when metrics data goes above or below certain thresholds.

**CAdvisor (Container Advisor)** is an open-source tool that collects and analyzes resource usage and performance metrics for containers. It provides detailed information about container resource usage, such as **CPU, memory, disk, and network usage, and can also help identify potential performance issues.**

![alt text for screen readers](/images/docker_monitoring.png "docker_containering")

**Postgres-exporter** is a tool that collects and exports **Postgres database metrics** to **Prometheus**. It can provide valuable insight into Postgres **performance**, such as the **number of active connections**, **query performance**, and **cache usage**. With **Postgres-exporter**, administrators can monitor **Postgres databases and quickly identify and resolve issues.**

![alt text for screen readers](/images/postgres_exporter.png "postgres_exporter")

*>> still In-pogress, sorry* https://grafana.com/oss/prometheus/exporters/postgres-exporter/

**pgAdmin** is a popular open-source administration and management tool for the PostgreSQL database. It provides an easy-to-use web interface that allows users to manage and interact with their PostgreSQL databases. pgAdmin allows users to perform various tasks, including creating and managing databases, creating and modifying tables, running queries, and managing users and permissions.
**Version 4.5 of pgAdmin** includes many features, such as a new dashboard that provides real-time statistics, a query tool that allows users to write and execute SQL queries, support for managing partitioned tables, support for PostgreSQL 13, and more. Additionally, pgAdmin 4.5 provides support for cloud-based PostgreSQL instances, making it easy to manage databases in the cloud.

![alt text for screen readers](/images/pg_admin_w_northwind_db.png "postgres_db")

**Prometheus Alertmanager** is an open-source tool for handling and sending alerts generated by Prometheus and other monitoring systems. It acts as a central hub for processing, **grouping**, **deduplicating**, and **routing alerts** to various notification channels like **email**, PagerDuty, Slack, and other third-party services. Alertmanager can also suppress duplicate alerts, classify alerts based on severity or type, and silence alerts for a specific time period or group. It provides a web interface for managing alerts, silences, and notification receivers, and allows for easy integration with other tools in the monitoring ecosystem. With Alertmanager, teams can quickly respond to issues and outages, ensuring high availability and reliability of their systems.

