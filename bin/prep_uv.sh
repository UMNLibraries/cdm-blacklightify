#!/usr/bin/env bash

# Must run from the bin directory directory
cd "$(dirname "$0")" || exit 1
# JS & CSS
cp -R ../node_modules/universalviewer/dist ../public/uv \
  && cp -R ../node_modules/universalviewer/dist/uv.css ../public/uv/uv.css

# Config
cp --no-clobber ../config/uv-config.json.example ../config/uv-config.json
ln --symbolic --relative --force ../config/uv-config.json ../public/uv/uv-config.json
