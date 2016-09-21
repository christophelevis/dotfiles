#!/bin/sh

# Exit on failure
set -e
 
usage() {
    echo "Usage: `basename $0` [start] [stop] [status] [dump] [reset (-P|M|O|MS) (host)]"
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

INSTANCE_ES=$(readlink $SONAR_CURRENT)-es
INSTANCE_CEWEB_1=$(readlink $SONAR_CURRENT)-ceweb1
INSTANCE_CEWEB_2=$(readlink $SONAR_CURRENT)-ceweb2

SONAR_PROPERTIES_FILE=conf/sonar.properties
GENER_START="# GENERATED START"
GENER_END="# GENERATED END"

cleanConfig () {
    if [ ! -f "$1/$SONAR_PROPERTIES_FILE.bak" ]
    then
        cp $1/$SONAR_PROPERTIES_FILE $1/$SONAR_PROPERTIES_FILE.bak
        echo >> $1/$SONAR_PROPERTIES_FILE
    fi
    sed -i "/$GENER_START/,/^$GENER_END/d" $1/$SONAR_PROPERTIES_FILE
}

removeCluster () {
    if [ -d "$INSTANCE_ES" ]
    then
        rm -rf $INSTANCE_ES
    fi
    if [ -d "$INSTANCE_CEWEB_1" ]
    then
        rm -rf $INSTANCE_CEWEB_1
    fi
    if [ -d "$INSTANCE_CEWEB_2" ]
    then
        rm -rf $INSTANCE_CEWEB_2
    fi
}

prepareCluster () {
    cp -r $(readlink $SONAR_CURRENT) $INSTANCE_ES
    cp -r $(readlink $SONAR_CURRENT) $INSTANCE_CEWEB_1
    cp -r $(readlink $SONAR_CURRENT) $INSTANCE_CEWEB_2
}

addConfig () {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # Configure dev update center
    echo "sonar.updatecenter.url=https://update.sonarsource.org/update-center-dev.properties" >> $1/$SONAR_PROPERTIES_FILE

    # set DB url & port
    if [ -n "$2" ]
    then
        echo "sonar.jdbc.url=$2" >> $1/$SONAR_PROPERTIES_FILE
    fi
    if [ -n "$3" ]
    then
        echo "sonar.embeddedDatabase.port=$3" >> $1/$SONAR_PROPERTIES_FILE
    fi

    # set DB credentials
    echo "sonar.jdbc.username=sonar" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.jdbc.password=sonar" >> $1/$SONAR_PROPERTIES_FILE  

    # Set secret key for auth
    echo "sonar.auth.jwtBase64Hs256Secret=MfKw3dS6tvaWsQlK06QvIDUkiw3r8+hgkJGOTNC30d8=" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

waitProcessUp () {
	TMP_LOGS=/tmp/tmplogs.$$
	mkfifo "${TMP_LOGS}"
	tail -f $1/logs/sonar.log > ${TMP_LOGS} &
	TAIL_PID=$!
	grep -m 1 -e "Process\[$2\] is up" "${TMP_LOGS}"
	kill "${TAIL_PID}"
	rm ${TMP_LOGS}
}

addConfigES () {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # set ES url & port
    echo "sonar.search.host=127.0.0.1" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.search.port=9010" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.enabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.ce.disabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.web.disabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.web.startupLeader=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.hosts=127.0.0.1:9010" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

addConfigCEWEB() {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # set WEB url & port
    # echo "sonar.web.host=127.0.0.1" >> $1/$SONAR_PROPERTIES_FILE
    if [ -n "$2" ]
    then
        echo "sonar.web.port=$2" >> $1/$SONAR_PROPERTIES_FILE
    fi

    echo "sonar.cluster.enabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.disabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.ce.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.web.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    case "$3" in
        "start")
            echo "sonar.cluster.web.startupLeader=true" >> $1/$SONAR_PROPERTIES_FILE
            ;;
        *)
            echo "sonar.cluster.web.startupLeader=false" >> $1/$SONAR_PROPERTIES_FILE
            ;;
    esac
    echo "sonar.cluster.search.hosts=127.0.0.1:9010" >> $1/$SONAR_PROPERTIES_FILE

    # enable DEBUG logs
    # echo "sonar.log.level=DEBUG" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

case "$1" in
    "start")
	echo "Starting es node"
	$INSTANCE_ES/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	waitProcessUp $INSTANCE_ES "es"
	echo "Starting ceweb1 node"
	$INSTANCE_CEWEB_1/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	waitProcessUp $INSTANCE_CEWEB_1 "ce"
	echo "Copy plugins from ceweb1 to ceweb2"
	cp $INSTANCE_CEWEB_1/extensions/plugins/* $INSTANCE_CEWEB_2/extensions/plugins/
	echo "Starting ceweb2 node"
	$INSTANCE_CEWEB_2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	waitProcessUp $INSTANCE_CEWEB_2 "ce"
	echo "Cluster started!"
        ;;

    "stop"|"status"|"dump")
	$INSTANCE_ES/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	$INSTANCE_CEWEB_1/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	$INSTANCE_CEWEB_2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
        ;;

    "reset")
	removeCluster
        cleanConfig $SONAR_CURRENT

        # print out properties for the correct DB
        case "$2" in
            "-P")
                echo "Use postgres on $SONAR_DB"
                SONAR_JDBC_URL="jdbc:postgresql://$SONAR_DB:5432/sonar"
                addConfig $SONAR_CURRENT $SONAR_JDBC_URL
                ;;
            "-M")
                echo "Use mysql on $SONAR_DB"
                SONAR_JDBC_URL="jdbc:mysql://$SONAR_DB:3306/sonar?autoReconnect=true&useUnicode=true&characterEncoding=utf8&useConfigs=maxPerformance"
                addConfig $SONAR_CURRENT $SONAR_JDBC_URL
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
                addConfig $SONAR_CURRENT $SONAR_JDBC_URL
                ;;
            "-MS")
                echo "Use MSsql on $SONAR_DB"
                SONAR_JDBC_URL="jdbc:jtds:sqlserver://$SONAR_DB/sonar;SelectMethod=Cursor"
                addConfig $SONAR_CURRENT $SONAR_JDBC_URL
                ;;
            "-H"|*)
                echo "Use local H2"
                SONAR_JDBC_URL="jdbc:h2:tcp://$SONAR_DB:9092/sonar"
                addConfig $SONAR_CURRENT $SONAR_JDBC_URL 9092
                ;;
        esac

        # clean temp data
        rm -rf $SONAR_CURRENT/data/*
        rm -rf $SONAR_CURRENT/logs/*

	prepareCluster
        addConfigES $INSTANCE_ES
        addConfigCEWEB $INSTANCE_CEWEB_1 9001 start
        addConfigCEWEB $INSTANCE_CEWEB_2 9002
	;;

    *)
        usage
        ;;
esac
