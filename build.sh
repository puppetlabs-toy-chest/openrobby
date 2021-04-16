#!/bin/bash

set -ex

export MIX_ENV=prod

mix local.hex --force
mix local.rebar --force

./clean.sh

mix deps.get
mix compile

(
  cd apps/robby_web
  rm -Rf node_modules
  npm install --production
  node_modules/brunch/bin/brunch build --production
  mix phx.digest
)

mix release
