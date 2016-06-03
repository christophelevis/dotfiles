#!/bin/sh

# Exit on failure
set -e

s-sonar.sh stop

# Check if build is required for plugins
for var in "$@"
do
    if [ "$var" = "-o" ]
    then
        echo "No build required for plugins"
        PLUGIN_BUILD_OPTION="-o"
    fi
done

# Get latest version of SonarQube
echo "Get latest version of SonarQube"
cd $REPOS/sonarqube
git pull

# Build!
echo "Build (quiet mode)..."
./quick-build.sh -q

# Unzip built package
echo "Extract distribution"
SONAR_VERSION=`ls $REPOS/sonarqube/sonar-application/target/sonarqube-*-SNAPSHOT.zip | sed 's/.*target\/sonarqube-\(.*\)-SNAPSHOT\.zip/\1/' `

rm -rf $SONAR_NEXT_FILES/INSTALL/*
unzip -q $REPOS/sonarqube/sonar-application/target/sonarqube-$SONAR_VERSION-SNAPSHOT.zip -d $SONAR_NEXT_FILES/INSTALL
rm $REPOS/sonarqube/sonar-application/target/sonarqube-$SONAR_VERSION-SNAPSHOT.zip

mv $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT/lib/bundled-plugins/*.jar $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT/extensions/plugins/

rm $SONAR_NEXT
ln -s $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT $SONAR_NEXT
rm $SONAR_CURRENT
ln -s $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT $SONAR_CURRENT

# Configure dev update center
echo "Configure SonarQube with dev update center"
echo "\n\nsonar.updatecenter.url=http://update.sonarsource.org/update-center-dev.properties" >> $SONAR_NEXT/conf/sonar.properties

# Restore backup plugins
echo "Restore plugins if any"
if [ "$(ls -A $SONAR_NEXT_FILES/BACKUP/)" ]
then
    cp $SONAR_NEXT_FILES/BACKUP/*.jar $SONAR_NEXT/extensions/plugins/
fi
 
# Checks if plugins must be installed or not
for var in "$@"
do
    if [ "$var" != "-o" ]
    then
        echo "Install latest version of plugin '$var'"
        s-installLatestVersionOfPlugin.sh $var $PLUGIN_BUILD_OPTION
    fi
done

echo "SonarQube '$SONAR_VERSION-SNAPSHOT' installed!"
