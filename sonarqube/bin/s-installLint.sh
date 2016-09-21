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
    SONAR_LINT_NAME="sonarlint-cli-$1"
    echo "Trying $SONAR_LINT_NAME on bintray..." >&2
    URL="https://sonarsource.bintray.com/Distribution/sonarlint-cli/$SONAR_LINT_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_LINT_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_LINT_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_LINT_NAME.zip -d "$SOFTWARE_FOLDER/SonarLint/"
    echo "Distribution unzipped in '$SONAR_LINT_NAME'" >&2
    echo "done"
}

dlAndExtractBuild() {
    SONAR_LINT_NAME="sonarlint-cli-$1"
    echo "Trying $SONAR_LINT_NAME on repox..." >&2
    URL="https://repox.sonarsource.com/sonarsource-public-releases/org/sonarsource/sonarlint/sonarlint-cli/$1/$SONAR_LINT_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_LINT_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_LINT_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_LINT_NAME.zip -d "$SOFTWARE_FOLDER/SonarLint/"
    echo "Distribution unzipped in 'sonarlint-$1'" >&2
    echo "done"
}

echo "Install sonarlint"

INSTALL_PATH=$SOFTWARE_FOLDER/SonarLint
if [ -d "$INSTALL_PATH/sonarlint-$1" ]
then
    echo "Version already installed"
else

    if [ -f $INSTALL_PATH/ARCHIVES/sonarlint-$1.zip ]
    then
        echo "Local archive 'sonarlint-$1.zip' found"
        unzip -q $INSTALL_PATH/ARCHIVES/sonarlint-$1.zip -d "$SOFTWARE_FOLDER/SonarLint/"
        echo "Distribution unzipped in 'sonarlint-$1'"
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

s-switchLint.sh $1
