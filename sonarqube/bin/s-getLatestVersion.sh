#!/bin/sh

# Exit on failure
set -e

cd $REPOS/sonarqube
git pull
./quick-build.sh
