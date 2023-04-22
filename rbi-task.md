###Task: 

#### Automate the installation and setup of a PostgreSQL DB with PgBouncer as a connection pooler

1. Take an existent simple test DB, northwind (Northwind sample.), an example of how to create the
database can be found in the README

2. Configure PgBouncer to authenticate users against the DB and direct incoming requests to
PostgreSQL:

a) Configure PgBouncer so that username and password are authenticated against PostgreSQL

without completely relying on userlist.txt.
b) Client connections to the DB should go through PGBouncer

3. Installation and configuration of PostgreSQL and PGBouncer should be automated as well as the
creation of the database

4. There is no automation tooling restriction but below you can find a list of tools you can orient on:
a) Dockerfiles
b) Ansible
c) **Docker Compose**  

Expected Outcome
1. Justification for all tool decisions (e.g., Ansible because of...).
2. You would be able to demo how the solution works
3. Document and present design, ideally with diagram
4. All written Artefacts in a zip archive or on a github repository :
1. Build files
2. Dockerfiles
3. any other glue code in any possible script/shell/bash language


To automate the installation and setup of a PostgreSQL DB with PgBouncer as a connection pooler and add the automatic database creation script to a Docker Compose file, I would do the following:

