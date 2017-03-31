#!/bin/sh

# Exit on failure
set -e
 
usage() {
    echo "Usage: `basename $0` [start|stop|status|dump (all|1|2|3)] [reset (all|1|2|3) (-P|M|O|MS) (host)] [clean]"
    echo "    -P start with postgres"
    echo "    -M start with mysql"
    echo "    -O start with oracle"
    echo "    -MS start with MSsql"
    echo "    -H start with H2 (default)"
    exit 0
}

case "$4" in 
    "")
        SONAR_DB="localhost"
        ;;
    *)
        SONAR_DB="$4"
        ;;
esac

INSTANCE_NODE=$(readlink $SONAR_CURRENT)-NODE

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
    if [ -d "${INSTANCE_NODE}1" ]
    then
        rm -rf ${INSTANCE_NODE}1
    fi
    if [ -d "${INSTANCE_NODE}2" ]
    then
        rm -rf ${INSTANCE_NODE}2
    fi
    if [ -d "${INSTANCE_NODE}3" ]
    then
        rm -rf ${INSTANCE_NODE}3
    fi
}

prepareCluster () {
    cp -r $(readlink $SONAR_CURRENT) ${INSTANCE_NODE}1
    cp -r $(readlink $SONAR_CURRENT) ${INSTANCE_NODE}2
    cp -r $(readlink $SONAR_CURRENT) ${INSTANCE_NODE}3
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

#waitProcessUp () {
#	TMP_LOGS=/tmp/tmplogs.$$
#	mkfifo "${TMP_LOGS}"
#	tail -f $1/logs/sonar.log > ${TMP_LOGS} &
#	TAIL_PID=$!
#	grep -m 1 -e "Process\[$2\] is up" "${TMP_LOGS}"
#	kill "${TAIL_PID}"
#	rm ${TMP_LOGS}
#}

addConfigNODE() {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # set WEB url & port
    # echo "sonar.web.host=" >> $2/$SONAR_PROPERTIES_FILE
    echo "sonar.web.port=$3" >> $1/$SONAR_PROPERTIES_FILE

    # set ES url & port
    echo "sonar.search.host=$2" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.search.port=$4" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.enabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.ce.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.web.disabled=false" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.hosts=$5" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.name=test_cluster" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.port=$6" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.hosts=$7" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.cluster.networkInterfaces=eth0" >> $1/$SONAR_PROPERTIES_FILE

    # enable DEBUG logs
    # echo "sonar.log.level=DEBUG" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

case "$1" in
    "start"|"stop"|"status"|"dump")
        case "$2" in
            all)
	        ${INSTANCE_NODE}1/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ${INSTANCE_NODE}2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
        	${INSTANCE_NODE}3/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
                ;;
            1|2|3)
        	${INSTANCE_NODE}$2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ;;
            *)
                usage
	        ;;
        esac
        ;;

    "reset")
	case "$2" in
	    all|1|2|3)
		;;
	    *)
		usage
		;;
	esac

	PLUGINS=$(ls -A "$SONAR_CURRENT/extensions/plugins/")
        if [ "$PLUGINS" = "README.txt" ]
        then
            echo "Run SonarQube in standalone mode first!"
            exit 1
        fi

	removeCluster
        cleanConfig $SONAR_CURRENT

        # print out properties for the correct DB
        case "$3" in
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

	NODE1_IP="10.0.2.11"
	NODE2_IP="10.0.2.12"
	NODE3_IP="10.0.2.13"

	NODE1_WEB_PORT="9001"
	NODE2_WEB_PORT="9002"
	NODE3_WEB_PORT="9003"

	NODE1_SEARCH_PORT="9011"
	NODE2_SEARCH_PORT="9012"
	NODE3_SEARCH_PORT="9013"

	NODE_CLUSTER_SEARCH_IPS="$NODE1_IP:$NODE1_SEARCH_PORT,$NODE2_IP:$NODE2_SEARCH_PORT,$NODE3_IP:$NODE3_SEARCH_PORT"

	NODE1_CLUSTER_PORT="9051"
	NODE2_CLUSTER_PORT="9052"
	NODE3_CLUSTER_PORT="9053"

	NODE_CLUSTER_IPS="$NODE1_IP:$NODE1_CLUSTER_PORT,$NODE2_IP:$NODE2_CLUSTER_PORT,$NODE3_IP:$NODE3_CLUSTER_PORT"

        case "$2" in
            all)
		NODE_IP="10.0.2.11"
		NODE_CLUSTER_SEARCH_IPS="$NODE_IP:$NODE1_SEARCH_PORT,$NODE_IP:$NODE2_SEARCH_PORT,$NODE_IP:$NODE3_SEARCH_PORT"
		NODE_CLUSTER_IPS="$NODE_IP:$NODE1_CLUSTER_PORT,$NODE_IP:$NODE2_CLUSTER_PORT,$NODE_IP:$NODE3_CLUSTER_PORT"

	        prepareCluster

                addConfigNODE ${INSTANCE_NODE}1 $NODE_IP $NODE1_WEB_PORT $NODE1_SEARCH_PORT $NODE_CLUSTER_SEARCH_IPS $NODE1_CLUSTER_PORT $NODE_CLUSTER_IPS
                addConfigNODE ${INSTANCE_NODE}2 $NODE_IP $NODE2_WEB_PORT $NODE2_SEARCH_PORT $NODE_CLUSTER_SEARCH_IPS $NODE2_CLUSTER_PORT $NODE_CLUSTER_IPS
                addConfigNODE ${INSTANCE_NODE}3 $NODE_IP $NODE3_WEB_PORT $NODE3_SEARCH_PORT $NODE_CLUSTER_SEARCH_IPS $NODE3_CLUSTER_PORT $NODE_CLUSTER_IPS
	        ;;

            1|2|3)
                addConfigNODE ${INSTANCE_NODE}$2 $NODE1_IP $NODE1_WEB_PORT $NODE1_SEARCH_PORT $NODE_CLUSTER_SEARCH_IPS $NODE1_CLUSTER_PORT $NODE_CLUSTER_IPS
	        ;;
        esac
        ;;

    "clean")
	removeCluster
        cleanConfig $SONAR_CURRENT

        # clean temp data
        rm -rf $SONAR_CURRENT/data/*
        rm -rf $SONAR_CURRENT/logs/*
        ;;

    *)
        usage
        ;;
esac
