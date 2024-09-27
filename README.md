# RenewCollab

![Logo](./guides/images/logo.png)

---

## Installation

### Prerequisites

The Elixir Crypto module used for password hashing needs to be compiled natively. On Windows this requires the Visual Studio compiler to available and set up correctly. On Linux GCC must be available in a comptatible version.

#### Windows

Setup Visual Studio Paths:

```
cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
mix deps.compile
```

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
mix run priv/repo/sees.exs
```

### Setup Account

Create your first account to log in with

```ex
RenewCollab.Auth.create_account("your@mail.org", "secret")
```