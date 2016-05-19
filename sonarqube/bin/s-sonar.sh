#!/bin/sh

# Exit on failure
set -e

setDefaultCredentials() {
    echo "sonar.jdbc.username=sonar" >> $SONAR_PROPERTIES_FILE
    echo "sonar.jdbc.password=sonar" >> $SONAR_PROPERTIES_FILE  
}

SONAR_PROPERTIES_FILE=$SONAR_CURRENT/conf/sonar.properties
SONAR_DB="localhost"

if [ "$1" = "start" ]
then 
  # clean the temp data
  s-clearDataFolder.sh

  # print out properties for the correct DB
  #if [ "$2" = "P" ] 
  #then
  #  echo "sonar.jdbc.url=$P_JDBC_URL" >> $SONAR_PROPERTIES_FILE
  #else
  #  if [ "$2" = "M" ] 
  #  then
  #    echo "sonar.jdbc.url=$M_JDBC_URL" >> $SONAR_PROPERTIES_FILE
  #  else
      if [ "$2" = "O" ] 
      then
        # copy the driver if it does not exist
        ORACLE_DRIVER="$SONAR_CURRENT/extensions/jdbc-driver/oracle/ojdbc6.jar"
        if [ ! -f "$ORACLE_DRIVER" ]
        then
          echo "Copying ORACLE driver"
          cp $SOFTWARE_FOLDER/SonarQube/oracle/ojdbc6.jar $SONAR_CURRENT/extensions/jdbc-driver/oracle/
        fi

  #      echo "sonar.jdbc.url=$O_JDBC_URL" >> $SONAR_PROPERTIES_FILE
  #    else
  #      if [ "$2" = "MS" ] 
  #      then
  #        echo "sonar.jdbc.url=$MS_JDBC_URL" >> $SONAR_PROPERTIES_FILE
  #      else
  #        echo "sonar.jdbc.url=$H_JDBC_URL" >> $SONAR_PROPERTIES_FILE
  #        echo "sonar.embeddedDatabase.port=9092" >> $SONAR_PROPERTIES_FILE
  #      fi
      fi
  #  fi
  #fi
  #setDefaultCredentials
fi

$SONAR_CURRENT/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
