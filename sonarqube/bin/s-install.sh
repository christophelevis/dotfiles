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
    SONAR_NAME=$1
    echo "Trying $SONAR_NAME on bintray..." >&2
    URL="https://sonarsource.bintray.com/Distribution/sonarqube/$SONAR_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/$SONAR_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/$SONAR_NAME.zip -d "$SOFTWARE_FOLDER/SonarQube/"
    echo "Distribution unzipped in '$SONAR_NAME'" >&2
    echo "done"
}

dlAndExtractBuild() {
    SONAR_NAME="sonar-application-$1"
    echo "Trying $SONAR_NAME on repox..." >&2
    URL="https://repox.sonarsource.com/sonarsource-public-releases/org/sonarsource/sonarqube/sonar-application/$1/$SONAR_NAME.zip"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Dowloading $SONAR_NAME..." >&2
    curl -L -# -o "$INSTALL_PATH/$SONAR_NAME.zip" "$URL"
    unzip -q $INSTALL_PATH/$SONAR_NAME.zip -d "$SOFTWARE_FOLDER/SonarQube/"
    echo "Distribution unzipped in 'sonarqube-$1'" >&2
    echo "done"
}

echo "Install sonarqube"

INSTALL_PATH=$SOFTWARE_FOLDER/SonarQube
if [ -d "$INSTALL_PATH/sonarqube-$1" ]
then
    echo "Build already installed"
else
    if [ -d "$INSTALL_PATH/sonarqube-$1" ]
    then
        echo "Build already installed"
    else

        if [ -f $INSTALL_PATH/sonarqube-$1.zip ]
        then
            echo "Local archive 'sonarqube-$1.zip' found"
            unzip -q $INSTALL_PATH/sonarqube-$1.zip -d "$SOFTWARE_FOLDER/SonarQube/"
            echo "Distribution unzipped in 'sonarqube-$1'"
        else
            if [ -f $INSTALL_PATH/sonar-$1.zip ]
            then
                echo "Local archive 'sonar-$1.zip' found"
                unzip -q $INSTALL_PATH/sonar-$1.zip -d "$SOFTWARE_FOLDER/SonarQube/"
                echo "Distribution unzipped in 'sonar-$1'"
            else
                if [ -f $INSTALL_PATH/sonar-application-$1.zip ]
                then
                    echo "Local archive 'sonar-application-$1.zip' found"
                    unzip -q $INSTALL_PATH/sonar-application-$1.zip -d "$SOFTWARE_FOLDER/SonarQube/"
                    echo "Distribution unzipped in 'sonarqube-$1'"
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
                        ret=$(dlAndExtractStable sonarqube-$1)
                        if [ ! "$ret" = "done" ]
                        then
                            ret=$(dlAndExtractStable sonar-$1)
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

s-switch.sh $1
