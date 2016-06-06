#!/bin/sh

# Exit on failure
set -e

case "$1" in 
    -h|--h|*-help)
        echo "Usage: `basename $0` [-o]"
        echo "    -o      prevent building the scanner"
        exit 0
        ;;
esac

echo "Install snapshot of scanner"

if [ "$2" = "-o" ]
then
    echo "No build required"
else
    echo "Get latest version of scanner"
    cd $REPOS/sonar-scanner-cli

    echo "Build (quiet mode)..."
    git pull
    mvn clean install -DskipTests -q
fi

BINARY="$REPOS/sonar-scanner-cli/target/sonar-scanner-*-SNAPSHOT.zip"
SCANNER_VERSION=`ls $REPOS/sonar-scanner-cli/target/sonar-scanner-*-SNAPSHOT.zip | sed 's/.*target\/sonar-scanner-\(.*\)-SNAPSHOT\.zip/\1/' `
echo "Extract scanner version '$SCANNER_VERSION'"

rm -rf $SONAR_SCANNER_NEXT_FILES/INSTALL/*
unzip -q $REPOS/sonar-scanner-cli/target/sonar-scanner-$SCANNER_VERSION-SNAPSHOT.zip -d $SONAR_SCANNER_NEXT_FILES/INSTALL

rm $SONAR_SCANNER_NEXT
ln -s $SONAR_SCANNER_NEXT_FILES/INSTALL/sonar-scanner-$SCANNER_VERSION-SNAPSHOT $SONAR_SCANNER_NEXT
rm $SONAR_SCANNER_CURRENT
ln -s $SONAR_SCANNER_NEXT_FILES/INSTALL/sonar-scanner-$SCANNER_VERSION-SNAPSHOT $SONAR_SCANNER_CURRENT

echo "Scanner '$SCANNER_VERSION-SNAPSHOT' installed!"
