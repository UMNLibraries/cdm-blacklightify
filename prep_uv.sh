#!/usr/bin/env bash

# JS & CSS
cp -R node_modules/universalviewer/dist/umd public/uv \
  && cp -R node_modules/universalviewer/dist/uv.css public/uv/uv.css

# Config
cp --no-clobber config/uv-config.json.example config/uv-config.json
ln --symbolic --relative --force config/uv-config.json public/uv/uv-config.json
