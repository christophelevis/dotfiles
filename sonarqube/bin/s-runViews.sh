#!/bin/sh

sonar-scanner views -Dsonar.login=admin -Dsonar.password=admin $*
