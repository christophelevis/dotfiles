#!/bin/sh

usage() {
    echo "Usage: `basename $0` [version]"
    echo "    where version can be 'snapshot', 'X.Y', 'X.Y-RC*', 'X.Y-build*...'"
    exit 0
}

CURRENT=""
case "$1" in 
    "")
        echo "Current version is unchanged"
        usage
        ;;
    "snapshot")
        VERSION="SNAPSHOT"
        CURRENT=$(readlink $SONAR_SCANNER_NEXT)
        ;;
    *)
        if [ -d $SOFTWARE_FOLDER/SonarScanner/sonar-scanner-$1 ] 
        then
            VERSION="$1"
            CURRENT=$SOFTWARE_FOLDER/SonarScanner/sonar-scanner-$1
        else
            echo "No install folder found for version $1"
            echo "Current version is unchanged"
            usage
        fi
        ;;
esac

if [ -n "$VERSION" ]
then
    rm $SONAR_SCANNER_CURRENT
    ln -s $CURRENT $SONAR_SCANNER_CURRENT
    echo "SonarScanner $VERSION configured as current installation"
fi
