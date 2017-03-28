#!/bin/sh

# No exit on failure
# set -e

case "$1" in 
    ""|-h|--h|*-help)
        echo "Usage: `basename $0` [VERSION] | [latest [BRANCH]]"
        echo "    VERSION:"
        echo "        X.Y"
        echo "        X.Y-RC*"
        echo "        X.Y.Z.*"
        echo "        X.Y-build*"
        echo "        latest (X.Y)"
        exit 0
        ;;
     "latest")
        case "$2" in
            "")
                BRANCH="master"
                ;;
            *)
                BRANCH="branch-$2"
                ;;
        esac
	LATEST=$(curl --silent "http://burgr.internal.sonarsource.com/api/commitPipelinesStages?project=SonarSource/sonarqube&branch=$BRANCH&nbOfCommits=50" | jq '[.[].pipelines[] | select(.stages[].type == "promotion")] | .[0]')
        if [ "$LATEST" = "null" ]
        then
            echo "No build found for branch '$BRANCH'!"
            exit 1
        fi
        VERSION=$(echo $LATEST | jq -r '.version')
        URL=$(echo $LATEST | jq -r '.versionUrl')
        ;;
     *)
        VERSION=$1
	URL=""
        ;;
esac

dlAndExtractStable() {
    SONAR_NAME=$1
    echo "Trying $SONAR_NAME on bintray..." >&2
    URL="https://sonarsource.bintray.com/Distribution/sonarqube/$SONAR_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Downloading $SONAR_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_NAME.zip -d "$SOFTWARE_FOLDER/SonarQube/$SONAR_NAME"
    echo "Distribution unzipped in '$SONAR_NAME'" >&2
    echo "done"
}

dlAndExtractBuild() {
    SONAR_NAME="sonar-application-$1"
    echo "Trying $SONAR_NAME on repox..." >&2
    if [ "$URL" = "" ]  
    then
        URL="https://repox.sonarsource.com/sonarsource-public-builds/org/sonarsource/sonarqube/sonar-application/$1/$SONAR_NAME.zip"
    fi

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Downloading $SONAR_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$SONAR_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/ARCHIVES/$SONAR_NAME.zip -d "$SOFTWARE_FOLDER/SonarQube/"
    echo "Distribution unzipped in 'sonarqube-$1'" >&2
    echo "done"
}

echo "Install sonarqube $VERSION"

INSTALL_PATH=$SOFTWARE_FOLDER/SonarQube
if [ -d "$INSTALL_PATH/sonarqube-$VERSION" ]
then
    echo "Version already installed"
else
    if [ -d "$INSTALL_PATH/sonarqube-$VERSION" ]
    then
        echo "Version already installed"
    else

        if [ -f $INSTALL_PATH/ARCHIVES/sonarqube-$VERSION.zip ]
        then
            echo "Local archive 'sonarqube-$VERSION.zip' found"
            unzip -q $INSTALL_PATH/ARCHIVES/sonarqube-$VERSION.zip -d "$SOFTWARE_FOLDER/SonarQube/"
            echo "Distribution unzipped in 'sonarqube-$VERSION'"
        else
            if [ -f $INSTALL_PATH/ARCHIVES/sonar-$VERSION.zip ]
            then
                echo "Local archive 'sonar-$VERSION.zip' found"
                unzip -q $INSTALL_PATH/ARCHIVES/sonar-$VERSION.zip -d "$SOFTWARE_FOLDER/SonarQube/"
                echo "Distribution unzipped in 'sonar-$VERSION'"
            else
                if [ -f $INSTALL_PATH/ARCHIVES/sonar-application-$VERSION.zip ]
                then
                    echo "Local archive 'sonar-application-$VERSION.zip' found"
                    unzip -q $INSTALL_PATH/ARCHIVES/sonar-application-$VERSION.zip -d "$SOFTWARE_FOLDER/SonarQube/"
                    echo "Distribution unzipped in 'sonarqube-$VERSION'"
                else

                    case "$VERSION" in 
                    *[0-9]\.[0-9]\.[0-9]\.*|*build*)
                        ret=$(dlAndExtractBuild $VERSION $URL)
                        if [ ! "$ret" = "done" ]
                        then
                            echo "Build not found!"
                            exit 1
                        fi
                        ;;
            
                    *)
                        ret=$(dlAndExtractStable sonarqube-$VERSION)
                        if [ ! "$ret" = "done" ]
                        then
                            ret=$(dlAndExtractStable sonar-$VERSION)
                            if [ ! "$ret" = "done" ]
                            then
                                echo "Version not found!"
                                exit 1
                            fi
                        fi
                        ;;
                    esac

                fi
            fi
        fi

    fi
fi

s-switch.sh $VERSION
