FROM elixir:1.12.2-alpine AS build

# Env
ENV MIX_ENV=prod

# Install dependencies
RUN apk update
RUN apk --no-cache --update add \
      make \
      g++ \
      wget \
      curl \
      inotify-tools \
      nodejs \
      npm

# Prepare App
COPY ./ /app
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest
RUN mix do compile, release


# Prepare release image
FROM alpine:3.15.0 AS app
ARG MIX_ENV=prod

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build --chown=nobody:nobody /app/_build/${MIX_ENV}/rel/deep_thought /app
RUN chown nobody:nobody /app

USER nobody:nobody
ENV HOME=/app
EXPOSE 4000

CMD ["bin/deep_thought", "start"]
