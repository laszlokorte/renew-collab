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
docker run\
-e PHX_HOST="localhost"\
-e PORT="8080"\
-e RENEW_ADMIN_EMAIL="your@email.net"\
-e RENEW_ADMIN_PASSWORD="your_password"\
-e SECRET_KEY_BASE="$(mix phx.gen.secret)"\
-p 8080:8080\
-it renew_collab
```

`RENEW_ADMIN_EMAIL` and `RENEW_ADMIN_PASSWORD` are the credentials to log into the Web Application.
Additional accounts can be created there.

`PORT` is the TCP port the webserver listens on for incoming connections. This port must be exposed by via `-p`. *Important:* Do not remap the internal port to a differnt external port. The Internal port is also used to generate absolute URLs inside the web applications. If internal and external ports differ, the generated URLs are invalid. 


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

---

[www.laszlokorte.de](//www.laszlokorte.de)