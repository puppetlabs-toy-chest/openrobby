#!/bin/bash

set -ex

rm -Rf package-work

mix deps.clean --all
mix clean --only
for app in apps/* ; do
  (
    cd $app
    mix clean --only
  )
done
