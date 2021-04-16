#!/bin/bash
mix local.hex --force
mix local.rebar --force
mix deps.get
mix deps.compile
