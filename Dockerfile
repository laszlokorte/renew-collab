# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240612-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.17.1-erlang-26.2.5-debian-bullseye-20240612-slim
#
ARG ELIXIR_VERSION=1.17.1
ARG OTP_VERSION=26.2.5
ARG DEBIAN_VERSION=bullseye-20240612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

ARG JAVA_VERSION="17"
ARG JAVA_BUILDER_IMAGE="eclipse-temurin:${JAVA_VERSION}"

FROM ${BUILDER_IMAGE} AS builder


ARG RENEW_DOCS_DB_TYPE="sqlite"
ARG RENEW_ACCOUNT_DB_TYPE="sqlite"
ARG RENEW_SIM_DB_TYPE="sqlite"

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"
ENV RENEW_DOCS_DB_TYPE=${RENEW_DOCS_DB_TYPE}
ENV RENEW_ACCOUNT_DB_TYPE=${RENEW_ACCOUNT_DB_TYPE}
ENV RENEW_SIM_DB_TYPE=${RENEW_SIM_DB_TYPE}

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# Use openJDK with alpine linux
FROM ${JAVA_BUILDER_IMAGE} AS java_builder

WORKDIR /interceptor

ADD priv/simulation/Interceptor.java Interceptor.java
ADD priv/simulation/manifest.txt manifest.txt

RUN javac Interceptor.java && jar cmf manifest.txt Interceptor.jar Interceptor.class
RUN java -jar Interceptor.jar echo

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}


ARG RENEW_DOWNLOAD_URL="https://www2.informatik.uni-hamburg.de/TGI/renew/4.1/renew4.1base.zip"
ARG RENEW_DOWNLOAD_TARGET="/tmp/renew-download.zip"
ARG JAVA_VERSION="17"

ARG DATA_ROOT_PATH="/data"
ENV DATA_ROOT_PATH=${DATA_ROOT_PATH}
ARG SIMULATOR_ROOT_PATH="/simulator"
ENV JAVA_VERSION=${JAVA_VERSION}

WORKDIR ${SIMULATOR_ROOT_PATH}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales \
  ca-certificates openjdk-$JAVA_VERSION-jdk wget xvfb unzip \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

ENV JAVA_HOME=/usr/lib/jvm/jdk-${JAVA_VERSION}/
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN java --version

COPY --from=java_builder /interceptor/Interceptor.jar "./Interceptor.jar"
COPY priv/simulation/log4j.properties "./log4j.properties"

RUN mkdir -p ./renew && \
    wget ${RENEW_DOWNLOAD_URL} -O ${RENEW_DOWNLOAD_TARGET} && \
    unzip ${RENEW_DOWNLOAD_TARGET} -d ./renew && \
    rm ${RENEW_DOWNLOAD_TARGET} && chown -R nobody:nogroup .

WORKDIR /text_metrics
COPY --chown=nobody:root priv/text_metrics/TextMeasure.java "./TextMeasure.java"

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

WORKDIR "/app"
RUN chown nobody:nogroup /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/renew_collab ./

RUN chmod +x /app/bin/server
RUN chmod +x /app/bin/migrate
RUN chmod +x /text_metrics/TextMeasure.java

VOLUME ["${DATA_ROOT_PATH}"]

RUN mkdir -p "${DATA_ROOT_PATH}"
RUN chown -R nobody:nogroup "${DATA_ROOT_PATH}"
RUN chmod 1777 /tmp
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && chown root:root /tmp/.X11-unix

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

ENV RENEW_DOCS_DB_PATH=${DATA_ROOT_PATH}/renew_docs.db
ENV RENEW_ACCOUNT_DB_PATH=${DATA_ROOT_PATH}/renew_auth.db
ENV RENEW_SIM_DB_PATH=${DATA_ROOT_PATH}/renew_sim.db
ENV SIM_RENEW_PATH=${SIMULATOR_ROOT_PATH}/renew
ENV SIM_STDIO_WRAPPER=${SIMULATOR_ROOT_PATH}/Interceptor.jar
ENV SIM_LOG4J_CONF=${SIMULATOR_ROOT_PATH}/log4j.properties
ENV RENEW_TEXT_MEASURE=/text_metrics/TextMeasure.java
ENV SIM_XVBF_DISPLAY=":23"
ENV PHX_HOST="localhost"
ENV PORT="4000"

CMD ["/app/bin/server"]
