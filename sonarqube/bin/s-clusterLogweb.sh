#!/bin/sh

usage() {
    echo "Usage: `basename $0` [1|2|3]"
    exit 0
}

case "$1" in
	1|2|3)
		tail -f $(readlink $SONAR_CURRENT)-NODE$1/logs/web.log
		;;
	*)
		usage
		;;
esac
