#!/bin/sh

# Exit on failure
set -e
 
usage() {
    echo "Usage: `basename $0` [start|stop|status|dump (all|app|es|0-9)] [reset (all|0-9) (-P|M|O|MS) (host)] [clean|cleanes|cleanlog]"
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
    if [ -d "${INSTANCE_NODE}4" ]
    then
        rm -rf ${INSTANCE_NODE}4
    fi
    if [ -d "${INSTANCE_NODE}5" ]
    then
        rm -rf ${INSTANCE_NODE}5
    fi
}

prepareCluster () {
    cp -r $(readlink $SONAR_CURRENT) ${INSTANCE_NODE}$1
    cp ${INSTANCE_NODE}$1/lib/bundled-plugins/* ${INSTANCE_NODE}$1/extensions/plugins/
}

addConfig () {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # Configure dev update center & co
    echo "sonar.updatecenter.url=https://update.sonarsource.org/update-center-dev.properties" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.telemetry.url=http://localhost/dev/null" >> $1/$SONAR_PROPERTIES_FILE

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

    # set passcode for monitoring
    echo "sonar.web.systemPasscode=admin+" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

addConfigAppNODE() {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # set WEB url & port
    echo "sonar.web.host=$2" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.web.port=$3" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.enabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.name=test_cluster" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.type=application" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.name=$4" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.host=$5" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.port=$6" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.hosts=$7" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.hosts=$8" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.node.web.port=$9" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.ce.port=$10" >> $1/$SONAR_PROPERTIES_FILE

    #echo "sonar.search.issues.shards=10" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.rules.shards=10" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.recovery.delayInMs=10000" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.recovery.minAgeInMs=30000" >> $1/$SONAR_PROPERTIES_FILE

    # enable DEBUG logs
    echo "sonar.log.level=DEBUG" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

addConfigEsNODE() {
    echo "$GENER_START" >> $1/$SONAR_PROPERTIES_FILE

    # set ES url & port
    echo "sonar.search.host=$2" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.search.port=$3" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.cluster.enabled=true" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.name=test_cluster" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.type=search" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.name=$4" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.host=$5" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.node.port=$6" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.hosts=$7" >> $1/$SONAR_PROPERTIES_FILE
    echo "sonar.cluster.search.hosts=$8" >> $1/$SONAR_PROPERTIES_FILE

    echo "sonar.search.httpPort=$9" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.issues.shards=10" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.rules.shards=10" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.recovery.delayInMs=10000" >> $1/$SONAR_PROPERTIES_FILE
    #echo "sonar.search.recovery.minAgeInMs=30000" >> $1/$SONAR_PROPERTIES_FILE

    # enable DEBUG logs
    echo "sonar.log.level=DEBUG" >> $1/$SONAR_PROPERTIES_FILE

    echo $GENER_END >> $1/$SONAR_PROPERTIES_FILE
}

case "$1" in
    "start"|"stop"|"status"|"dump")
        case "$2" in
            all)
		#ES
		${INSTANCE_NODE}3/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
		${INSTANCE_NODE}4/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
		${INSTANCE_NODE}5/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1

		#App
	        ${INSTANCE_NODE}1/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ${INSTANCE_NODE}2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
                ;;
            [0-9])
        	${INSTANCE_NODE}$2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ;;
            app)
	        ${INSTANCE_NODE}1/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ${INSTANCE_NODE}2/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ;;
            es)
		${INSTANCE_NODE}3/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
		${INSTANCE_NODE}4/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
		${INSTANCE_NODE}5/bin/$SONAR_WRAPPER_FOLDER/sonar.sh $1
	        ;;
            *)
                usage
	        ;;
        esac
        ;;

    "reset")
	case "$2" in
	    all|[0-9])
		;;
	    *)
		usage
		;;
	esac

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

	NODE1_WEB_PORT="9001"
	NODE2_WEB_PORT="9002"

	NODE3_SEARCH_PORT="9013"
	NODE4_SEARCH_PORT="9014"
	NODE5_SEARCH_PORT="9015"

	NODE1_CLUSTER_WEB_PORT="9021"
	NODE2_CLUSTER_WEB_PORT="9022"
	NODE1_CLUSTER_CE_PORT="9031"
	NODE2_CLUSTER_CE_PORT="9032"

	NODE1_CLUSTER_NAME="App-1"
	NODE2_CLUSTER_NAME="App-2"
	NODE3_CLUSTER_NAME="ES-3"
	NODE4_CLUSTER_NAME="ES-4"
	NODE5_CLUSTER_NAME="ES-5"

	NODE1_CLUSTER_PORT="9051"
	NODE2_CLUSTER_PORT="9052"
	NODE3_CLUSTER_PORT="9053"
	NODE4_CLUSTER_PORT="9054"
	NODE5_CLUSTER_PORT="9055"

	NODE3_SEARCH_HTTP_PORT="9093"
	NODE4_SEARCH_HTTP_PORT="9094"
	NODE5_SEARCH_HTTP_PORT="9095"

        case "$2" in
            all)
		NODE1_IP="10.0.2.11"
		NODE2_IP="10.0.2.11"
		NODE3_IP="10.0.2.11"
		NODE4_IP="10.0.2.11"
		NODE5_IP="10.0.2.11"

		NODE1_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE2_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE3_CLUSTER_SEARCH_IPS="$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE4_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE5_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT"
		NODE_CLUSTER_IPS="$NODE1_IP:$NODE1_CLUSTER_PORT,$NODE2_IP:$NODE2_CLUSTER_PORT,$NODE3_IP:$NODE3_CLUSTER_PORT,$NODE4_IP:$NODE4_CLUSTER_PORT,$NODE5_IP:$NODE5_CLUSTER_PORT"

	        prepareCluster 1
	        prepareCluster 2
	        prepareCluster 3
	        prepareCluster 4
	        prepareCluster 5

                addConfigAppNODE ${INSTANCE_NODE}1 $NODE1_IP $NODE1_WEB_PORT $NODE1_CLUSTER_NAME $NODE1_IP $NODE1_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE1_CLUSTER_SEARCH_IPS $NODE1_CLUSTER_WEB_PORT $NODE2_CLUSTER_WEB_PORT
                addConfigAppNODE ${INSTANCE_NODE}2 $NODE2_IP $NODE2_WEB_PORT $NODE2_CLUSTER_NAME $NODE2_IP $NODE2_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE2_CLUSTER_SEARCH_IPS $NODE1_CLUSTER_CE_PORT $NODE2_CLUSTER_CE_PORT
                addConfigEsNODE ${INSTANCE_NODE}3 $NODE3_IP $NODE3_SEARCH_PORT $NODE3_CLUSTER_NAME $NODE3_IP $NODE3_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE3_CLUSTER_SEARCH_IPS $NODE3_SEARCH_HTTP_PORT
                addConfigEsNODE ${INSTANCE_NODE}4 $NODE4_IP $NODE4_SEARCH_PORT $NODE4_CLUSTER_NAME $NODE4_IP $NODE4_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE4_CLUSTER_SEARCH_IPS $NODE4_SEARCH_HTTP_PORT
                addConfigEsNODE ${INSTANCE_NODE}5 $NODE5_IP $NODE5_SEARCH_PORT $NODE5_CLUSTER_NAME $NODE5_IP $NODE5_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE5_CLUSTER_SEARCH_IPS $NODE5_SEARCH_HTTP_PORT
	        ;;

            1|2)
		NODE1_IP="10.0.2.11"
		NODE2_IP="10.0.2.12"
		NODE3_IP="10.0.2.13"
		NODE4_IP="10.0.2.14"
		NODE5_IP="10.0.2.15"

		NODE1_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE2_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE3_CLUSTER_SEARCH_IPS="$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE4_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE5_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT"
		NODE_CLUSTER_IPS="$NODE1_IP:$NODE1_CLUSTER_PORT,$NODE2_IP:$NODE2_CLUSTER_PORT,$NODE3_IP:$NODE3_CLUSTER_PORT,$NODE4_IP:$NODE4_CLUSTER_PORT,$NODE5_IP:$NODE5_CLUSTER_PORT"

	        prepareCluster $2

		NODE_IP="NODE${2}_IP"
		NODE_WEB_PORT="NODE${2}_WEB_PORT"
		NODE_SEARCH_PORT="NODE${2}_SEARCH_PORT"
		NODE_CLUSTER_WEB_PORT="NODE${2}_CLUSTER_WEB_PORT"
		NODE_CLUSTER_CE_PORT="NODE${2}_CLUSTER_CE_PORT"
		NODE_CLUSTER_SEARCH_IPS="NODE${2}_CLUSTER_SEARCH_IPS"
		NODE_CLUSTER_NAME="App-${2}"
		NODE_CLUSTER_PORT="NODE${2}_CLUSTER_PORT"
		NODE_SEARCH_HTTP_PORT="NODE${2}_SEARCH_HTTP_PORT"
                addConfigAppNODE ${INSTANCE_NODE}$2 $NODE_IP $NODE_WEB_PORT $NODE_CLUSTER_NAME $NODE_IP $NODE_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE_CLUSTER_SEARCH_IPS $NODE_CLUSTER_WEB_PORT $NODE_CLUSTER_WEB_PORT
	        ;;
            3|4|5)
		NODE1_IP="10.0.2.11"
		NODE2_IP="10.0.2.12"
		NODE3_IP="10.0.2.13"
		NODE4_IP="10.0.2.14"
		NODE5_IP="10.0.2.15"

		NODE1_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE2_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE3_CLUSTER_SEARCH_IPS="$NODE4_IP:$NODE4_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE4_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE5_IP:$NODE5_SEARCH_PORT"
		NODE5_CLUSTER_SEARCH_IPS="$NODE3_IP:$NODE3_SEARCH_PORT,$NODE4_IP:$NODE4_SEARCH_PORT"
		NODE_CLUSTER_IPS="$NODE1_IP:$NODE1_CLUSTER_PORT,$NODE2_IP:$NODE2_CLUSTER_PORT,$NODE3_IP:$NODE3_CLUSTER_PORT,$NODE4_IP:$NODE4_CLUSTER_PORT,$NODE5_IP:$NODE5_CLUSTER_PORT"

	        prepareCluster $2

		NODE_IP="NODE${2}_IP"
		NODE_WEB_PORT="NODE${2}_WEB_PORT"
		NODE_SEARCH_PORT="NODE${2}_SEARCH_PORT"
		NODE_CLUSTER_SEARCH_IPS="NODE${2}_CLUSTER_SEARCH_IPS"
		NODE_CLUSTER_NAME="ES-${2}"
		NODE_CLUSTER_PORT="NODE${2}_CLUSTER_PORT"
		NODE_SEARCH_HTTP_PORT="NODE${2}_SEARCH_HTTP_PORT"
                addConfigEsNODE ${INSTANCE_NODE}$2 $NODE_IP $NODE_SEARCH_PORT $NODE_CLUSTER_NAME $NODE_IP $NODE_CLUSTER_PORT $NODE_CLUSTER_IPS $NODE_CLUSTER_SEARCH_IPS $NODE_SEARCH_HTTP_PORT
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

    "cleanes")
	rm -rf ${INSTANCE_NODE}1/data/*
	rm -rf ${INSTANCE_NODE}2/data/*
	rm -rf ${INSTANCE_NODE}3/data/*
	rm -rf ${INSTANCE_NODE}4/data/*
	rm -rf ${INSTANCE_NODE}5/data/*
        ;;

    "cleanlog")
	rm -rf ${INSTANCE_NODE}1/logs/*
	rm -rf ${INSTANCE_NODE}2/logs/*
	rm -rf ${INSTANCE_NODE}3/logs/*
	rm -rf ${INSTANCE_NODE}4/logs/*
	rm -rf ${INSTANCE_NODE}5/logs/*
        ;;

    *)
        usage
        ;;
esac
