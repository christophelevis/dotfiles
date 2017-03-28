#!/bin/bash

# No exit on failure
# set -e

case "$1" in 
    -h|--h|*-help)
        echo "Usage: `basename $0` [-p] [-a]"
        echo "    -p      clean plugins"
        echo "    -a      clean archives"
        exit 0
        ;;
esac

echo "Uninstall build versions of sonarqube, scanner and plugins"

DIR_LIST=""
FILE_LIST=""

cleanSonarQube() {
    echo "SonarQube"
    for dir in ~/Software/SonarQube/*
    do
        if [ -d "$dir" ]
        then
            case $dir in
                *sonarqube-*-build*|*sonarqube-[0-9]*.[0-9]*.[0-9]*.[0-9]*)
    		    DIR_LIST="$DIR_LIST $dir"
                    echo "# $dir"
                    ;;
            esac
        fi
    done
}

cleanSonarScanner() {
    echo "SonarScanner"
    for dir in ~/Software/SonarScanner/*
    do
        if [ -d "$dir" ]
        then
            case $dir in
                *sonar-scanner-*-build*|*sonar-scanner-[0-9]*.[0-9]*.[0-9]*.[0-9]*)
    		    DIR_LIST="$DIR_LIST $dir"
                    echo "# $dir"
                    ;;
            esac
        fi
    done
}

cleanPlugins() {
    echo "Plugins"
    for file in ~/Software/SonarQube/sonarqube-*/extensions/plugins/*
    do
        if [ -f "$file" ]
        then
            case $file in
                *sonar-*-plugin-*-build*.jar|*sonar-*-plugin-[0-9]*.[0-9]*.[0-9]*.[0-9]*.jar)
    		    FILE_LIST="$FILE_LIST $file"
                    echo "# $file"
                    ;;
            esac
        fi
    done
}

cleanArchives() {
    echo "Archives    "
    for file in ~/Software/SonarQube/ARCHIVES/*
    do
        if [ -f "$file" ]
        then
            case $file in
                *sonar-application-*.zip)
    		    FILE_LIST="$FILE_LIST $file"
                    echo "# $file"
                    ;;
            esac
        fi
    done
    for file in ~/Software/SonarScanner/ARCHIVES/*
    do
        if [ -f "$file" ]
        then
            case $file in
                *sonar-scanner-cli-*.zip)
    		    FILE_LIST="$FILE_LIST $file"
                    echo "# $file"
                    ;;
        esac
    fi
    done
    for file in ~/Software/SonarQube/ARCHIVES/*
    do
        if [ -f "$file" ]
        then
            case $file in
                *-plugin-*-build*.jar|*-plugin-[0-9]*.[0-9]*.[0-9]*.[0-9]*.jar)
    		    FILE_LIST="$FILE_LIST $file"
                    echo "# $file"
                    ;;
            esac
        fi
    done
}

case "$1" in
    "-p")
        cleanPlugins
        ;;
    "-a")
        cleanArchives
        ;;
esac

cleanSonarQube
cleanSonarScanner

if [ -z "$DIR_LIST" ] && [ -z "$FILE_LIST" ]
then
    echo "Nothing to clean"
    exit 0
fi

read -p "Are you sure? [n] " -n1
echo ""
case $REPLY in
    y|Y)
        rm -r $FILE_LIST $DIR_LIST
        echo "Done"
        ;;
    *)
        echo "Nothing done"
        ;;
esac
