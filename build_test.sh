#!/usr/bin/env bash
set -Eeu

make test TARGET="${*:1}"