#!/bin/sh
SONAR_VERSION=`ls -l $SOFTWARE_FOLDER/SonarQube/current | sed 's/.*>.*-\([0-9].*\)/\1/' `
echo "Current version => $SONAR_VERSION"
