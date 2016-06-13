#!/bin/sh

# Exit on failure
set -e
 
usage() {
    echo "Usage: `basename $0` [start] [stop] [restart] [status] [dump] [reset (-P|M|O|MS) (host)]"
    echo "    -P start with postgres"
    echo "    -M start with mysql"
    echo "    -O start with oracle"
    echo "    -MS start with MSsql"
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

case "$1" in
    "start"|"stop"|"restart"|"status"|"dump")
	$SONAR_CURRENT/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
        ;;

    "reset")
        # print out properties for the correct DB
        case "$2" in
            "-P")
                echo "Use postgres on $SONAR_DB"
                SONAR_P_JDBC_URL="jdbc:postgresql://$SONAR_DB:5432/sonar"
                echo "sonar.jdbc.url=$SONAR_P_JDBC_URL" >> $SONAR_PROPERTIES_FILE
                ;;
            "-M")
                echo "Use mysql on $SONAR_DB"
                SONAR_M_JDBC_URL="jdbc:mysql://$SONAR_DB:3306/sonar?autoReconnect=true&useUnicode=true&characterEncoding=utf8&useConfigs=maxPerformance"
                echo "sonar.jdbc.url=$SONAR_M_JDBC_URL" >> $SONAR_PROPERTIES_FILE
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
                SONAR_O_JDBC_URL="jdbc:oracle:thin:@$SONAR_DB:1521/ORCL"
                echo "sonar.jdbc.url=$SONAR_O_JDBC_URL" >> $SONAR_PROPERTIES_FILE
                ;;
            "-MS")
                echo "Use MSsql on $SONAR_DB"
                SONAR_MS_JDBC_URL="jdbc:jtds:sqlserver://$SONAR_DB/sonar;SelectMethod=Cursor"
                echo "sonar.jdbc.url=$SONAR_MS_JDBC_URL" >> $SONAR_PROPERTIES_FILE
                ;;
            *)
                echo "Use local H2"
                SONAR_H_JDBC_URL="jdbc:h2:tcp://$SONAR_DB:9092/sonar"
                echo "sonar.jdbc.url=$SONAR_H_JDBC_URL" >> $SONAR_PROPERTIES_FILE
                echo "sonar.embeddedDatabase.port=9092" >> $SONAR_PROPERTIES_FILE
                ;;
        esac

        # set credentials
        echo "sonar.jdbc.username=sonar" >> $SONAR_PROPERTIES_FILE
        echo "sonar.jdbc.password=sonar" >> $SONAR_PROPERTIES_FILE  

        # clean temp data
        rm -rf $SONAR_CURRENT/data/*
        rm -rf $SONAR_CURRENT/logs/*
	;;

    *)
        usage
        ;;
esac
