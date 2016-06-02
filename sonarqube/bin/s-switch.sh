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
        CURRENT=$SONAR_NEXT
        ;;
    *)
        if [ -d $SOFTWARE_FOLDER/SonarQube/sonarqube-$1 ] 
        then
            VERSION="$1"
            CURRENT=$SOFTWARE_FOLDER/SonarQube/sonarqube-$1
        elif [ -d $SOFTWARE_FOLDER/SonarQube/sonar-$1 ] 
        then
            VERSION="$1"
            CURRENT=$SOFTWARE_FOLDER/SonarQube/sonar-$1
        else
            echo "No SQ install folder found for version $1"
            echo "Current version is unchanged"
            usage
        fi
        ;;
esac

if [ -n "$VERSION" ]
then
    s-sonar.sh stop
    rm $SONAR_CURRENT
    ln -s $CURRENT $SONAR_CURRENT
    echo "SonarQube $VERSION configured as current installation"
fi
