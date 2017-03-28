#!/bin/sh

# Exit on failure
set -e
 
usage() {
    echo "Usage: `basename $0` [start] [stop] [restart] [status] [dump] [reset (-P|M|O|MS) (host)]"
    echo "    -P start with postgres"
    echo "    -M start with mysql"
    echo "    -O start with oracle"
    echo "    -MS start with MSsql"
    echo "    -H start with H2 (default)"
    exit 0
}

case "$3" in 
    "")
        SONAR_DB="localhost"
        ;;
    *)
        SONAR_DB="$3"
        ;;
esac

SONAR_PROPERTIES_FILE=$SONAR_CURRENT/conf/sonar.properties
GENER_START="# GENERATED START"
GENER_END="# GENERATED END"

cleanConfig () {
    if [ ! -f "$SONAR_PROPERTIES_FILE.bak" ]
    then
        cp $SONAR_PROPERTIES_FILE $SONAR_PROPERTIES_FILE.bak
        echo >> $SONAR_PROPERTIES_FILE
    fi
    sed -i "/$GENER_START/,/^$GENER_END/d" $SONAR_PROPERTIES_FILE
}

addConfig () {
    echo "$GENER_START" >> $SONAR_PROPERTIES_FILE

    # Configure dev update center
    echo "sonar.updatecenter.url=https://update.sonarsource.org/update-center-dev.properties" >> $SONAR_PROPERTIES_FILE

    # set DB url & port
    if [ -n "$1" ]
    then
        echo "sonar.jdbc.url=$1" >> $SONAR_PROPERTIES_FILE
    fi
    if [ -n "$2" ]
    then
        echo "sonar.embeddedDatabase.port=$2" >> $SONAR_PROPERTIES_FILE
    fi

    # set DB credentials
    echo "sonar.jdbc.username=sonar" >> $SONAR_PROPERTIES_FILE
    echo "sonar.jdbc.password=sonar" >> $SONAR_PROPERTIES_FILE  

    echo $GENER_END >> $SONAR_PROPERTIES_FILE
}

case "$1" in
    "start"|"stop"|"restart"|"status"|"dump")
	$SONAR_CURRENT/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
        ;;

    "reset")
        cleanConfig

        # print out properties for the correct DB
        case "$2" in
            "-P")
                echo "Use postgres on $SONAR_DB"
                SONAR_JDBC_URL="jdbc:postgresql://$SONAR_DB:5432/sonar"
                addConfig $SONAR_JDBC_URL
                ;;
            "-M")
                echo "Use mysql on $SONAR_DB"
                SONAR_JDBC_URL="jdbc:mysql://$SONAR_DB:3306/sonar?autoReconnect=true&useUnicode=true&characterEncoding=utf8&useConfigs=maxPerformance"
                addConfig $SONAR_JDBC_URL
                ;;
            "-O")
                echo "Use oracle on $SONAR_DB"
                # copy the driver if it does not exist
                ORACLE_DRIVER="$SONAR_CURRENT/extensions/jdbc-driver/oracle/ojdbc6.jar"
                if [ ! -f "$ORACLE_DRIVER" ]
                then
                    echo "Copying oracle driver"
                    cp $SOFTWARE_FOLDER/SonarQube/DRIVERS/oracle/ojdbc6.jar $SONAR_CURRENT/extensions/jdbc-driver/oracle/
                fi
                SONAR_JDBC_URL="jdbc:oracle:thin:@$SONAR_DB:1521/ORCL"
                addConfig $SONAR_JDBC_URL
                ;;
            "-MS")
                echo "Use MSsql on $SONAR_DB"
                # copy the driver if it does not exist
                MSSQL_DRIVER_DIR="$SONAR_CURRENT/extensions/jdbc-driver/mssql"
                MSSQL_DRIVER="$MSSQL_DRIVER/sqljdbc4.jar"
                if [ ! -f "$MSSQL_DRIVER" ]
                then
                    echo "Copying MSsql driver"
                    if [ ! -d "$MSSQL_DRIVER_DIR" ]
                    then
                        mkdir $MSSQL_DRIVER_DIR
                    fi
                    cp $SOFTWARE_FOLDER/SonarQube/DRIVERS/mssql/sqljdbc4.jar $SONAR_CURRENT/extensions/jdbc-driver/mssql/
                fi
                # SONAR_JDBC_URL="jdbc:jtds:sqlserver://$SONAR_DB/sonar;SelectMethod=Cursor"
                SONAR_JDBC_URL="jdbc:sqlserver://$SONAR_DB;databaseName=sonar"
                addConfig $SONAR_JDBC_URL
                ;;
            "-H"|*)
                echo "Use local H2"
                SONAR_JDBC_URL="jdbc:h2:tcp://$SONAR_DB:9092/sonar"
                addConfig $SONAR_JDBC_URL 9092
                ;;
        esac

        # clean temp data
        rm -rf $SONAR_CURRENT/data/*
        rm -rf $SONAR_CURRENT/logs/*
	;;

    *)
        usage
        ;;
esac
