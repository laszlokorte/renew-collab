# RenewCollab

![Logo](./guides/images/logo.png)

---

## Installation

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