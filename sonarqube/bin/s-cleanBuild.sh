#!/bin/bash

# No exit on failure
# set -e

echo "Uninstall build versions of sonarqube, scanner and plugins"

DIR_LIST=""
FILE_LIST=""

echo "SonarQube"
for dir in ~/Software/SonarQube/*
do
    if [ -d "$dir" ]
    then
        case $dir in
            *sonarqube-*-build*)
		DIR_LIST="$DIR_LIST $dir"
                echo "# $dir"
                ;;
        esac
    fi
done
echo "SonarScanner"
for dir in ~/Software/SonarScanner/*
do
    if [ -d "$dir" ]
    then
        case $dir in
            *sonar-scanner-*-build*)
		DIR_LIST="$DIR_LIST $dir"
                echo "# $dir"
                ;;
        esac
    fi
done
echo "Plugins"
for file in ~/Software/SonarQube/sonarqube-*/extensions/plugins/*
do
    if [ -f "$file" ]
    then
        case $file in
            *sonar-*-plugin-*-build*.jar)
		FILE_LIST="$FILE_LIST $file"
                echo "# $file"
                ;;
        esac
    fi
done

echo "Archives"
for file in ~/Software/SonarQube/ARCHIVES/*
do
    if [ -f "$file" ]
    then
        case $file in
            *sonar-application-*-build*.zip)
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
            *sonar-scanner-cli-*-build*.zip)
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
            *-plugin-*-build*.jar)
		FILE_LIST="$FILE_LIST $file"
                echo "# $file"
                ;;
        esac
    fi
done

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
