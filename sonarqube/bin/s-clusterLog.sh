#!/bin/sh

usage() {
    echo "Usage: `basename $0` [es|ceweb1|ceweb2]"
    exit 0
}

case "$1" in
	es|ceweb1|ceweb2)
		tail -f $(readlink $SONAR_CURRENT)-$1/logs/sonar.log
		;;
	*)
		usage
		;;
esac
