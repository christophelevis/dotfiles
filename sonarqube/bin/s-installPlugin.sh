#!/bin/sh

# No exit on failure
# set -e

usage() {
        echo "Usage: `basename $0` [PLUGIN] [VERSION]"
        echo "    PLUGIN:"
        echo "        java"
        echo "        javascript"
        echo "        ..."
        echo "    VERSION:"
        echo "        X.Y"
        echo "        X.Y-build*"
        exit 0
}

case "$1" in 
    ""|-h|--h|*-help)
        usage
        ;;
    *)
        case "$2" in 
            ""|-h|--h|*-help)
                usage
                ;;
        esac
        PLUGIN=$1
        VERSION=$2
        ;;
esac

dlAndExtractStable() {
    PLUGIN_NAME="sonar-$1-plugin"
    echo "Trying $PLUGIN_NAME-$2 on bintray (distribution)..." >&2
    URL="https://sonarsource.bintray.com/Distribution/$PLUGIN_NAME/$PLUGIN_NAME-$2.jar"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "Trying $PLUGIN_NAME-$2 on bintray (commercial distribution)..." >&2
        URL="https://sonarsource.bintray.com/CommercialDistribution/$PLUGIN_NAME/$PLUGIN_NAME-$2.jar"

        HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
        if [ ! "$HTTP_CODE" = "200" ]  
        then
            echo "error"
            return
        fi
    fi

    echo "Downloading $PLUGIN_NAME-$2..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$PLUGIN_NAME-$2.jar" "$URL"
    cp $INSTALL_PATH/ARCHIVES/$PLUGIN_NAME-$2.jar $SONAR_CURRENT/extensions/plugins/
    echo "Plugin '$PLUGIN_NAME-$2' copied" >&2
    echo "done"
}

dlAndExtractBuild() {
    PLUGIN_NAME="$1-extension-plugin"
    DEPLOY_NAME="sonar-$1-plugin-$2"
    echo "Trying $PLUGIN_NAME-$2 on repox..." >&2
    URL="https://repox.sonarsource.com/sonarsource-public-releases/org/sonarsource/$1/$PLUGIN_NAME/$2/$PLUGIN_NAME-$2.jar"

    HTTP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null --head "$URL")
    if [ ! "$HTTP_CODE" = "200" ]  
    then
        echo "error"
        return
    fi

    echo "Downloading $PLUGIN_NAME-$2..." >&2
    curl -L -# -o "$INSTALL_PATH/ARCHIVES/$PLUGIN_NAME-$2.jar" "$URL"
    cp $INSTALL_PATH/ARCHIVES/$PLUGIN_NAME-$2.jar $SONAR_CURRENT/extensions/plugins/$DEPLOY_NAME.jar
    echo "Plugin '$DEPLOY_NAME' copied" >&2
    echo "done"
}

echo "Install plugin"

INSTALL_PATH=$SOFTWARE_FOLDER/SonarQube
if [ -f "$SONAR_CURRENT/extensions/plugins/sonar-$PLUGIN-plugin-$VERSION.jar" ]
then
    echo "Version already installed"
else

    if [ -f $INSTALL_PATH/ARCHIVES/sonar-$PLUGIN-plugin-$VERSION.jar ]
    then
        echo "Local copy 'sonar-$PLUGIN-plugin-$VERSION.jar' found"
        cp $INSTALL_PATH/ARCHIVES/sonar-$PLUGIN-plugin-$VERSION.jar $SONAR_CURRENT/extensions/plugins/
        echo "Plugin copied"
    else
        if [ -f $INSTALL_PATH/ARCHIVES/$PLUGIN-extension-plugin-$VERSION.jar ]
        then
            echo "Local copy '$PLUGIN-extension-plugin-$VERSION' found"
            cp $INSTALL_PATH/ARCHIVES/$PLUGIN-extension-plugin-$VERSION.jar $SONAR_CURRENT/extensions/plugins/sonar-$PLUGIN-plugin-$VERSION.jar
            echo "Plugin copied"
        else

            case "$VERSION" in 
            *build*)
                ret=$(dlAndExtractBuild $PLUGIN $VERSION)
                if [ ! "$ret" = "done" ]
                then
                    echo "Build not found!"
                    exit 1
                fi
                ;;
    
            *)
                ret=$(dlAndExtractStable $PLUGIN $VERSION)
                if [ ! "$ret" = "done" ]
                then
                    echo "Version not found!"
                    exit 1
                fi
                ;;
            esac

        fi
    fi

fi
