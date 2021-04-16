#!/bin/sh

set -e

bundle install --deployment

for a in configs/projects/*.rb ; do
  project=$(basename ${a%.rb})

  for p in configs/platforms/*.rb ; do
    platform=$(basename ${p%.rb})
    echo
    echo ======================================================================
    echo Building and packaging $project for $platform
    echo ======================================================================
    bundle exec build "${project}" "${platform}"
  done
done
