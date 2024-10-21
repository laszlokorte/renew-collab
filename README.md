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
-e PORT="3000"\
-e ADMIN_EMAIL="your@email.net"\
-e ADMIN_PASSWORD="your_password"\
-e SECRET_KEY_BASE="$(mix phx.gen.secret)"\
-p 8080:3000\
-it renew_collab
```

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

Create your first account to log in with.

Run the elixir command below. If you have started the server with the command above you have the REPL already running and can type it in.

```ex
RenewCollabAuth.Auth.create_account("your@mail.org", "secret")
```

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

---

[www.laszlokorte.de](//www.laszlokorte.de)