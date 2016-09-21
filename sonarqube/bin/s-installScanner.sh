#!/bin/sh

# No exit on failure
# set -e

case "$1" in 
    ""|-h|--h|*-help)
        echo "Usage: `basename $0` [VERSION]"
        echo "    VERSION:"
        echo "        X.Y"
        echo "        X.Y-RC*"
        echo "        X.Y-build*"
        exit 0
        ;;
esac

dlAndExtractStable() {
    SONAR_SCANNER_NAME="sonar-scanner-$1"
    echo "Trying $SONAR_SCANNER_NAME on bintray..." >&2
    URL="https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/$SONAR_SCANNER_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_SCANNER_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_SCANNER_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_SCANNER_NAME.zip -d "$SOFTWARE_FOLDER/SonarScanner/"
    echo "Distribution unzipped in '$SONAR_SCANNER_NAME'" >&2
    echo "done"
}

dlAndExtractBuild() {
    SONAR_SCANNER_NAME="sonar-scanner-cli-$1"
    echo "Trying $SONAR_SCANNER_NAME on repox..." >&2
    URL="https://repox.sonarsource.com/sonarsource-public-releases/org/sonarsource/scanner/cli/sonar-scanner-cli/$1/$SONAR_SCANNER_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_SCANNER_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_SCANNER_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_SCANNER_NAME.zip -d "$SOFTWARE_FOLDER/SonarScanner/"
    echo "Distribution unzipped in 'sonar-scanner-$1'" >&2
    echo "done"
}

echo "Install sonar-scanner"

INSTALL_PATH=$SOFTWARE_FOLDER/SonarScanner
if [ -d "$INSTALL_PATH/sonar-scanner-$1" ]
then
    echo "Version already installed"
else

    if [ -f $INSTALL_PATH/ARCHIVES/sonar-scanner-$1.zip ]
    then
        echo "Local archive 'sonar-scanner-$1.zip' found"
        unzip -q $INSTALL_PATH/ARCHIVES/sonar-scanner-$1.zip -d "$SOFTWARE_FOLDER/SonarScanner/"
        echo "Distribution unzipped in 'sonar-scanner-$1'"
    else

        case "$1" in 
        *build*)
            ret=$(dlAndExtractBuild $1)
            if [ ! "$ret" = "done" ]
            then
                echo "Build not found!"
                exit 1
            fi
            ;;
            
        *)
            ret=$(dlAndExtractStable $1)
            if [ ! "$ret" = "done" ]
            then
                echo "Version not found!"
                exit 1
            fi
            ;;
        esac

    fi
fi

s-switchScanner.sh $1
