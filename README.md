# RenewCollab

![Logo](./guides/images/logo.png)

---

## Docker

To run this project as a docker container (recommended for production) follow the steps below:

### Build Image

```sh
# Inside project root
docker build -t renew_collab:latest .
```

### Run Container

```sh 
docker run \
-e PHX_HOST="localhost" \
-e PORT="8080" \
-e PORT_EXTERNAL="9000" \
-e RENEW_ADMIN_EMAIL="your@email.net" \
-e RENEW_ADMIN_PASSWORD="your_password" \
-e SECRET_KEY_BASE="yLJm+iFU1ExOHIT3lSSafaC+XCTYklG67xDI2Qd6eAMD3XulUUYfg181Jci8idqN" \
-p 9000:8080 \
-it renew_collab
```

`RENEW_ADMIN_EMAIL` and `RENEW_ADMIN_PASSWORD` are the credentials to log into the Web Application.
Additional accounts can be created there.

`PORT` is the TCP port the webserver listens on for incoming connections. This port must be exposed by via `-p`. 
`PORT_EXTERNAL` is the port that is used for generating URLs. This may differ from `PORT` if the application is running behind a proxy. In the example above `-p 9000:8080` is used to map the port 9000 from the host machine to the port 8080 of the container. Thus the webserver listens on port 8080 but to access the application from the host machines network `http://localhost:9000` must be used. 

`mix phx.gen.secret` above is used to generate a random squence of at least 64 bytes. You can generate such a random seed for `SECRET_KEY_BASE` by others means, eg if you do not have mix and phoenix installed when running the container. `SECRET_KEY_BASE` is used for encrypting and signing cookies.



### Open in Browser

[localhost:8080](http://localhost:8080)

## Manual Installation

To run this project without docker one your own machine for development follow the steps below.

### Prerequisites

* [Erlang](https://www.erlang.org/) is installed on your machine ([instructions](https://www.erlang.org/downloads))
* [Elixir](https://elixir-lang.org/) is installed on your machine ([instructions](https://elixir-lang.org/install.html))
* [NodeJS](https://nodejs.org/en) is installed on your machine ([instructions](https://nodejs.org/en/download/prebuilt-installer))

### Clone this repository

Download this repostitory onto your machine.

```sh
git clone url-to-this-repository
```

### Install dependencies

```sh
# Inside this project directory
mix deps.get
``` 

### Compile dependencies 

This step is needed if the GLIBC version on your machine differs from the one used in the precompiled SQlite adapter.

```sh
# Inside this project directory
mix deps.compile
``` 

### Compile Project

```sh
# Inside this project directory
mix compile
``` 

### Create Database and run migrations

```sh
# Inside this project directory
mix ecto.create
mix ecto.migrate
```

### Run Seeding Script

To import predefined data into the database (eg. symbols and socket_schemas)

```sh
# Inside this project directory
mix run priv/repo/seeds.exs
```

### Compile JavaScript assets

```sh
# Inside this project directory
mix setup
```

### Start Dev Server with REPL

```sh
# Inside this project directory
iex -S mix phx.server
```

### Setup Account

Create your first admin account to log in with.

Run the elixir command below. If you have started the server with the command above you have the REPL already running and can type it in.

```ex
RenewCollabAuth.Auth.create_account("your@mail.org", "secret", true)
```

The third parameter (`true`) makes the new account an admin account, that is authorized to create further accounts via the web UI.

### Open in Browser

[localhost:4000](http://localhost:4000)

## Contributing

### Automatic Code Formatting

To automatically format all elixir code in the project run:

```sh
mix format
```

### Git pre-commit hook

To check the code formatting before every git commit, setup the git `pre-commit` hook:

```sh
cp priv/dev/git-hooks/pre-commit .git/hooks/pre-commit
```

## Database Schema

By SQLite is used as database. Once the `mix ecto.migrate` command has been run (see above) the database file `renew_collab_dev.db` is created inside this projects root folder. The database schema is defined and maintained via migration scripts inside [priv/repo/migrations](./priv/repo/migrations) file.

To get an overview of the full schema, take a look at the plot in the guides ([guides/db_schema.svg](./guides/db_schema.svg)).

### Regenerate DB schema plot

If you change the database schema during development you should generate the plot ([guides/db_schema.svg](./guides/db_schema.svg)). To do this use [schemacrawler](https://www.schemacrawler.com) and run it with the following command line options:

```sh
schemacrawler --info-level=standard --command=schema --output-format=svg --portable-names --server sqlite --database ./renew_collab_dev.db --output-file=guides/db_schema.svg
```

## Other Database Backends

When build the docker image (or running `mix compile`) you can specify what kind of SQL database should be used to store user accounts, documents, and simulation state. You can chose between `mysql`, `sqlite`, and `postgresql` for each.

In the example below MySQL is used to store user accounts, PostgreSQL is used to store the documents and SQLite is used for storing the simulation states:

```sh
docker build \
--build-arg RENEW_ACCOUNT_DB_TYPE=mysql \
--build-arg RENEW_DOCS_DB_TYPE=postgresql \
--build-arg RENEW_SIM_DB_TYPE=sqlite 
-t renew_collab_mixed_db:latest .
```

The *kind* of databases must be determined at compile time (when building the Docker image). But the exact databases to be used are configured at run time (when container is started).

```sh 
docker run\
-e PHX_HOST="localhost"\
-e PORT="8080"\
-e PORT_EXTERNAL="9000"\
-e RENEW_ADMIN_EMAIL="your@email.net"\
-e RENEW_ADMIN_PASSWORD="your_password"\
-e SECRET_KEY_BASE="$(mix phx.gen.secret)"\
-e RENEW_ACCOUNT_DB_URL="mysql://myuser:mypass@mysqlhost:3306/renew_accounts"\
-e RENEW_DOCS_DB_URL="postgresql://pguser:pgpass@pghost:5432/renew_documents"\
-e RENEW_SIM_DB_PATH="/data/renew_sim.db"\
--net renew-network
-p 9000:8080\
-it renew_collab
```

In the command above the environment variables `RENEW_ACCOUNT_DB_URL` and `RENEW_DOCS_DB_URL` are set to contain the credentials for the MySql and PostgreSQL databases respectively. Additionally the `RENEW_SIM_DB_PATH` is set to file location inside the container at which the SQLite database should be stored. The SQLite storage location could also be ommited and will default to the `/data` directory inside the container.

**Important (1)**: As explained above, the *kind* of database to be used is determined at compile/build time. The credentials are provided at startup time. Which credentials must be provided at startup time depends on the kind of database selected at build time.

Setting `RENEW_ACCOUNT_DB_TYPE` to `mysql` or `postgresql` *requires* `RENEW_ACCOUNT_DB_URL` to be set.
Setting `RENEW_ACCOUNT_DB_TYPE` to `sqlite` allows `RENEW_ACCOUNT_DB_PATH` to be set, but falls back to default value `/data/renew_auth.db`.

**Important (2)**: Make sure that the database server is on the same network as the application container.

---

[www.laszlokorte.de](//www.laszlokorte.de)