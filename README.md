# RenewCollab

## Windows

Setup Visual Studio Paths:

```
cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
mix deps.compile
```

## Setup Account

```ex
RenewCollab.Auth.create_account("your@mail.org", "secret")
```