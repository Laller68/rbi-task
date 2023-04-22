### Deployment of the Postgres DB poller and Postgres monitoring 

**Task:**

I choose the docker-compose deployment with helps of Docker environment


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

## Docker Compose with the following steps:

1. Create a new folder for the project.
2. Create a docker-compose.yaml file in the root directory of the folder.
3. Configure the docker-compose.yaml file as follows:

```bash
version: '3.7'

volumes:
  postgres_data: {}
  pgadmin: {}
  prometheus_data: {}
  grafana_data: {}
  alertmanager_data: {}  

services:

  postgresdb:
  #  image: postgres:12
    image: postgres_northwind:latest
    container_name: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data     
#      - ./northwind_db.sql:/docker-entrypoint-initdb.d/northwind_db.sql
      - ./create_tables.sql:/docker-entrypoint-initdb.d/create_tables.sql
    restart: always
    environment:
      POSTGRES_USER: hho
      POSTGRES_PASSWORD: northwind!pw
      POSTGRES_DB: Northwind    
    
    ports:
      - 5432:5432    

  pgbouncer:
    image: pgbouncer/pgbouncer
    container_name: pgbouncer
    restart: always
    
    depends_on:
      - postgresdb
     
    
    environment:
      # AUTH_TYPE: md5
      # AUTH_FILE: /etc/pgbouncer/userlist.txt
      PGBOUNCER_AUTH_USER: hho
      PGBOUNCER_AUTH_PASSWORD: northwind!pw
      PGBOUNCER_DEFAULT_POOL_SIZE: 20
      PGBOUNCER_MAX_CLIENT_CONN: 100
      PGBOUNCER_POOL_MODE: session
      PGBOUNCER_POOL_SIZE: 20
      PGBOUNCER_SERVER_IDLE_TIMEOUT: 60
      PGBOUNCER_SERVER_IDLE_TRANSACTION_TIMEOUT: 300
      PGBOUNCER_SERVER_ROUND_ROBIN: 1
      PGBOUNCER_SERVERS: postgresdb:5432/Northwind
      
    ports:
      - 6432:6432 

  # portainer:
    # image: portainer/portainer-ce:latest
    # container_name: portainer
    # restart: unless-stopped
    # security_opt:
      # - no-new-privileges:true
    # volumes:
      # - /etc/localtime:/etc/localtime:ro
      # - /var/run/docker.sock:/var/run/docker.sock:ro
      # - ./portainer-data:/data
    # ports:
      # - 9000:9000
     
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    volumes:
      - prometheus_data:/prometheus
  #   - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
  #    - /home/laller/prometheus.yml:/etc/prometheus/prometheus.yml:ro 
      
    ports:
      - 9090:9090  

    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
      - '--web.route-prefix=/'
      - '--web.external-url=/prometheus/'
    restart: always  
    depends_on:
      - cadvisor
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
       - 8080:8080
    volumes:
       - /:/rootfs:ro
       - /var/run:/var/run:rw
       - /sys:/sys:ro
  #     - /var/lib/docker/:/var/lib/docker:ro
    restart: always
  alertmanager:
    image: prom/alertmanager
    container_name: alertmanager
    volumes:
      - alertmanager_data:/alertmanager/

    restart: always
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
  grafana:
    image: grafana/grafana-enterprise:9.3.2-ubuntu
    container_name: grafana
    user: "root"

    links:
      - prometheus	  
    depends_on:

      - prometheus
    volumes:
      - grafana_data:/var/lib/grafana

    environment:
      - GF_SERVER_DOMAIN=grafana
      - GF_SERVER_ROOT_URL=%(protocol)s://%(domain)s:%(http_port)s/grafana/
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
      - GF_USERS_DEFAULT_THEME=dark
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: always
    
    ports:
      - 3000:3000
    
  pgadmin_client:
    container_name: pgadmin4-container
    image: dpage/pgadmin4
    restart: unless-stopped
    expose:
      - 5050
    environment:
      PGADMIN_DEFAULT_EMAIL: lajos.misurda@gmail.com
      PGADMIN_DEFAULT_PASSWORD: postgres
    volumes:
      - pgadmin:/var/lib/pgadmin      
    ports:
      - 5050:80
      
  postgres-exporter:
    image: wrouesnel/postgres_exporter:v0.8.0
    container_name: postgres-exporter
    restart: always
    environment:
      #- DATA_SOURCE_NAME=postgresql://postgres:password@postgres-db:5432/postgres?sslmode=disable
      - DATA_SOURCE_URI=postgresdb:5432/postgres?sslmode=disable
      - DATA_SOURCE_USER=postgres
      - DATA_SOURCE_PASS=password
    ports:
      - 9187:9187
         
    depends_on:
      - postgresdb         
```

## PgBouncer Docker container configuration

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