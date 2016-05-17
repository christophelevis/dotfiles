#!/bin/sh

echo "Building SonarQube scanner"

if [ "$2" = "-o" ]
then
  echo "(no build required)"
else
  cd $REPOS/sonar-scanner-cli
  git pull
  mvn clean install -DskipTests
fi
echo ""

BINARY="$REPOS/sonar-scanner-cli/target/sonar-scanner-*-SNAPSHOT.zip"
scannerVersion=`ls $BINARY | sed 's/.*target\/sonar-scanner-\(.*\)-SNAPSHOT\.zip/\1/' `
echo "Extracting scanner $scannerVersion"

rm -rf $SONAR_SCANNER_NEXT_FILES/INSTALL/*
unzip -q $BINARY -d $SONAR_SCANNER_NEXT_FILES/INSTALL
echo "Scanner unzipped"

rm $SONAR_SCANNER_NEXT
ln -s $SONAR_SCANNER_NEXT_FILES/INSTALL/sonar-scanner-$scannerVersion-SNAPSHOT $SONAR_SCANNER_NEXT
rm $SONAR_SCANNER_CURRENT
ln -s $SONAR_SCANNER_NEXT_FILES/INSTALL/sonar-scanner-$scannerVersion-SNAPSHOT $SONAR_SCANNER_CURRENT

