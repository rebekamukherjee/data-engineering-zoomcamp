# Running Postgres and pgAdmin with Docker-Compose

## Docker Compose

In the previous lesson we ran Postgres and pgAdmin in one network using two docker commands. There is a lot of configuration and it is not very convenient. Instead, we can have a single file with configuration for both the containers and that specifies that both the containers belong to the same network.

`Docker Compose` is a tool for defining and running multi-container Docker applications. With Compose, we use a `YAML` file to configure our application's services. Then, with a single command, we can create and start all the services from the configuration.

We can run `docker-compose` if we have installed Docker Desktop. If not, we need to follow the instructions on how to install it.

# configing docker compose

We need to create a file called **docker-compose.yaml**

> docker-compose.yaml
```yaml
services:
    pgdatabase:
        image: postgres:13
        environment:
            - POSTGRES_USER=root
            - POSTGRES_PASSWORD=root
            - POSTGRES_DB=ny_taxi
        volumes:
            - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"
        ports:
            - "5432:5432"
    pgadmin:
        image: dpage/pgadmin4
        environment:
            - PGADMIN_DEFAULT_EMAIL=admin@admin.com
            - PGADMIN_DEFAULT_PASSWORD=root
        ports:
            - "8080:80"
```
- Volume mapping: `volumes` >  **hostPath:containerPath:mode** > `"./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"`
- In Docker Compose we don't need to specify the full path, we can use relative path instead.
- The mode is `rw` which stands for *read write*.

## Running Docker Compose

First, stop all docker containers. Run the command `docker ps` to check if any containers are running.

Next, run the command `docker-compose up`

This will create the containers for Postgres (`pgdatabase`) and pgAdmin (`pgadmin`), and create the connection between them.

Now, go to **localhost:8080**, refresh the pgAdmin interface, and use the email and password from the docker run command to sign in.

We need to create a new server called `Docker localhost` with the correct database name. In the `Connection` tab add:
- Host name = `pgdatabase`
- Port = `5432`
- Maintainence database = `postgres`
- Username = `root`
- Password = `root`

Now we can check if the pipeline has worked correctly by running queries in pgAdmin.

# Stopping Docker Compose

To stop Docker Compose, enter `ctrl + c` and then run the command `docker-compose down`

If we want to run Docker Compose with stdout logs in the terminal we can run it in detached mode. The command for that is `docker-compose up -d` . To shut down the detached mode we don't need to enter `ctrl + c`, we can just run `docker-compose down`.