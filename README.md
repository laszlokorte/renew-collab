# RenewCollab

![Logo](./guides/images/logo.png)

---

## Docker

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

### Install dependencies

```sh
mix deps.get
``` 

### Compile JavaScript assets

```sh
mix setup
```

### Create Database and run migrations

```
mix ecto.create
mix ecto.migrate
```

### Run Seeding Script

To import predefined data into the database (eg. symbols and socket_schemas)

```
mix run priv/repo/seeds.exs
```

### Setup Account

Create your first account to log in with

```ex
RenewCollabAuth.Auth.create_account("your@mail.org", "secret")
```


---

[www.laszlokorte.de](//www.laszlokorte.de)