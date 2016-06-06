#!/bin/sh

# Exit on failure
set -e

case "$1" in 
    -h|--h|*-help)
        echo "Usage: `basename $0` ..."
	s-installSnapshotOfPlugin.sh -help
        exit 0
        ;;
esac

echo "Install snapshot of sonarqube"

s-sonar.sh stop

# Get latest version of sonarqube
echo "Get latest version"
cd $REPOS/sonarqube
git pull

# Build!
echo "Build (quiet mode)..."
./quick-build.sh -q

# Unzip built package
SONAR_VERSION=`ls $REPOS/sonarqube/sonar-application/target/sonarqube-*-SNAPSHOT.zip | sed 's/.*target\/sonarqube-\(.*\)-SNAPSHOT\.zip/\1/' `
echo "Extract sonarqube version '$SONAR_VERSION'"

rm -rf $SONAR_NEXT_FILES/INSTALL/*
unzip -q $REPOS/sonarqube/sonar-application/target/sonarqube-$SONAR_VERSION-SNAPSHOT.zip -d $SONAR_NEXT_FILES/INSTALL
rm $REPOS/sonarqube/sonar-application/target/sonarqube-$SONAR_VERSION-SNAPSHOT.zip

mv $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT/lib/bundled-plugins/*.jar $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT/extensions/plugins/

rm $SONAR_NEXT
ln -s $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT $SONAR_NEXT
rm $SONAR_CURRENT
ln -s $SONAR_NEXT_FILES/INSTALL/sonarqube-$SONAR_VERSION-SNAPSHOT $SONAR_CURRENT

# Configure dev update center
echo "Configure sonarqube with dev update center"
echo "\n\nsonar.updatecenter.url=http://update.sonarsource.org/update-center-dev.properties" >> $SONAR_NEXT/conf/sonar.properties

# Restore backup plugins
echo "Restore plugins if any"
if [ "$(ls -A $SONAR_NEXT_FILES/BACKUP/)" ]
then
    cp $SONAR_NEXT_FILES/BACKUP/*.jar $SONAR_NEXT/extensions/plugins/
fi
 
if [ -n "$1" ]
then
    s-installSnapshotOfPlugin.sh $1
fi

echo "Sonarqube '$SONAR_VERSION-SNAPSHOT' installed!"
