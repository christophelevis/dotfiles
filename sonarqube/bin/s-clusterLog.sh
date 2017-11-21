#!/bin/sh

usage() {
    echo "Usage: `basename $0` [0-9]"
    exit 0
}

case "$1" in
	[0-9])
		tail -f $(readlink $SONAR_CURRENT)-NODE$1/logs/sonar.log
		;;
	*)
		usage
		;;
esac
