#!/bin/sh

usage() {
    echo "Usage: `basename $0` [1|2|3]"
    exit 0
}

case "$1" in
	1|2|3)
		vi $(readlink $SONAR_CURRENT)-NODE$1/conf/sonar.properties
		;;
	*)
		usage
		;;
esac
