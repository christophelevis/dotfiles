#!/bin/sh

if [ "$1" = "" ] 
then
  CURRENT=$SONAR_SCANNER_NEXT
  echo "SonarScanner SNAPSHOT configured as current installation."
else
  if [ -d $SOFTWARE_FOLDER/SonarScanner/sonar-scanner-$1 ] 
  then
    CURRENT=$SOFTWARE_FOLDER/SonarScanner/sonar-scanner-$1
    echo "SonarScanner $1 configured as current installation."
  else
  	echo "No SQ install folder found for version $1"
  	echo "Current version is unchanged"
  fi
fi

if [ "$CURRENT" != "" ]
then
	rm $SONAR_SCANNER_CURRENT
	ln -s $CURRENT $SONAR_SCANNER_CURRENT
fi
