#!/bin/sh
SCANNER_VERSION=`ls -l $SOFTWARE_FOLDER/SonarScanner/current | sed 's/.*>.*-\([0-9].*\)/\1/' `
echo "Current version => $SCANNER_VERSION"
