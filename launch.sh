#!/bin/bash

cd "$(dirname "$0")"

xvfb-run pipenv run proxy
