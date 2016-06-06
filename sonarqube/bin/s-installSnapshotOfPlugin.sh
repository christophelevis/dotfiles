#!/bin/sh

# Exit on failure
set -e

case "$1" in 
    ""|-h|--h|*-help)
        echo "Usage: `basename $0` [PLUGINS] [-o]"
        echo "    PLUGINS list of plugin to install"
        echo "    -o      prevent building the plugins"
        exit 0
        ;;
esac

deployPlugin() {
    if [ "$2" = "" ]
    then 
        # Simple plugin
        NAME=$1
        BINARY="$REPOS/sonar-$PLUGIN/target/sonar-$PLUGIN-plugin-*-SNAPSHOT.jar"
    else
        # Multi-JAR plugin
        NAME=$2
        BINARY="$REPOS/sonar-$PLUGIN/sonar-$2-plugin/target/sonar-$2-plugin-*-SNAPSHOT.jar"
    fi
  
    echo "Deploy plugin '$NAME'"
    rm -f $PLUGINS_DEV/sonar-$NAME-plugin-*.jar
    cp $BINARY $PLUGINS_DEV
    echo "$NAME deployed"
}

installPlugin() {
    PLUGIN=$1
    echo "Install snapshot of plugin '$PLUGIN'"

    if [ "$2" = "-o" ]
    then
        echo "No build required"
    else
        echo "Get latest version of plugin"
        cd $REPOS/sonar-$PLUGIN

        echo "Build (quiet mode)..."
        git pull
        mvn clean install -DskipTests -q
    fi

    PLUGINS_LIST=`ls $REPOS/sonar-$PLUGIN | grep plugin | sed 's/sonar-\(.*\)-plugin/\1/'`
    if [ -z "$PLUGINS_LIST" ]
    then
        # Simple plugin
        deployPlugin $PLUGIN
    else
        # Multi-JAR plugin
        for p in $PLUGINS_LIST
        do
            deployPlugin $PLUGIN $p
        done
    fi
}

#Check if build is required for plugins
PLUGIN_BUILD_OPTION=""
for var in "$@"
do
    if [ "$var" = "-o" ]
    then
        echo "No build required for plugins"
        PLUGIN_BUILD_OPTION="-o"
    fi
done

# Checks if plugins must be installed or not
for var in "$@"
do
    if [ "$var" != "-o" ]
    then
        installPlugin $var $PLUGIN_BUILD_OPTION
    fi
done
