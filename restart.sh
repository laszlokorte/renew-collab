#!/usr/bin/env bash

export MIX_ENV=prod 
export DATABASE_PASSWORD="51498920e6fbfa58f0cbc"
export SECRET_KEY_BASE="XG81azvd05GQIZrpqcfkBltr5JjX8IdbmSa/MILwd3AdRakAdBsdT+1Idzhn17E0"
export RENEW_DOCS_DB_PATH="/home/laszlo7/renew_collab_deployed_docs.db"
export RENEW_AUTH_DB_PATH="/home/laszlo7/renew_collab_deployed_auth.db"
export RENEW_SIM_DB_PATH="/home/laszlo7/renew_collab_deployed_sim.db"
export SIM_RENEW_PATH="/home/laszlo7/renew-java/renew41"
export SIM_STDIO_WRAPPER="/home/laszlo7/renew_collab_deployed/priv/simulation/Interceptor.jar"
export SIM_LOG4J_CONF="/home/laszlo7/renew_collab_deployed/priv/simulation/log4j.properties"
export SIM_XVBF="/usr/bin/xvfb-run"

mix deps.get
mix compile
mix ecto.migrate 
supervisorctl reread
supervisorctl update
supervisorctl restart renew-collab
