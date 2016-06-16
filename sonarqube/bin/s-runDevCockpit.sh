#!/bin/sh

sonar-scanner devcockpit -Dsonar.login=admin -Dsonar.password=admin $*
