#!/bin/sh

# Exit on failure
set -e

# Activate organizations
curl -X POST -u admin:admin http://localhost:9000/api/organizations/enable_support
curl --data "key=sonar.organizations.anyoneCanCreate&value=true" -X POST -u admin:admin http://localhost:9000/api/settings/set
curl --data "key=sonar.organizations.createPersonalOrg&value=true" -X POST -u admin:admin http://localhost:9000/api/settings/set

# Add users
curl --data "login=foo&name=Foo&password=admin&password_confirmation=admin" -X POST -u admin:admin "http://localhost:9000/api/users/create"
curl --data "login=bar&name=Bar&password=admin&password_confirmation=admin" -X POST -u admin:admin "http://localhost:9000/api/users/create"

