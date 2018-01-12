#!/usr/bin/env bash

##
## Reset to beginning of Reactive Microservices
## Desired State:
##   monolith solution deployed in "coolstore-dev" project
##   inventory solution deployed in "inventory" project
##   catalog solution deployed in "catalog" project
##

if [ "$(oc whoami)" != "developer" ] ; then
	echo "must login as developer first"
	exit 1
fi

# delete all projects
oc delete project --all
while [ -n "$(oc get projects -o name)" ]; do
  echo "waiting for all projects to delete..."
  sleep 5
done

# sleep a bit more
echo "All projects deleted. Waiting 60 seconds to ensure they are gone"
sleep 60

# clean the workspace
cd $HOME/projects
git reset --hard
git clean -df
git clean -Xf

# checkout solution and deploy monolith to dev project
cd $HOME/projects/monolith
git checkout solution
oc new-project coolstore-dev --display-name="Coolstore Monolith - Dev"
oc new-app coolstore-monolith-binary-build
mvn clean package -Popenshift
oc start-build coolstore --from-file=deployments/ROOT.war

# deploy inventory solution to inventory project
cd $HOME/projects/inventory
oc new-project inventory --display-name="CoolStore Inventory Microservice Application" || { echo "cant create project; ensure all projects gone with 'oc get projects' and try again"; exit 1; }
oc new-app -e POSTGRESQL_USER=inventory \
           -e POSTGRESQL_PASSWORD=mysecretpassword \
           -e POSTGRESQL_DATABASE=inventory \
           openshift/postgresql:latest \
           --name=inventory-database

mvn clean fabric8:deploy -Popenshift

# deploy catalog solution to catalog project
cd $HOME/projects/catalog
oc new-project catalog --display-name="CoolStore Catalog Microservice Application" || { echo "cant create project; ensure all projects gone with 'oc get projects' and try again"; exit 1; }
oc new-app -e POSTGRESQL_USER=catalog \
             -e POSTGRESQL_PASSWORD=mysecretpassword \
             -e POSTGRESQL_DATABASE=catalog \
             openshift/postgresql:latest \
             --name=catalog-database

mvn clean package fabric8:deploy -Popenshift -DskipTests

# go back to master to start at the right place for scenario
mvn clean
git clean -df
git clean -Xf
git checkout master

# start in right directory
echo "---"
echo "Reset complete. To start in the right place: cd $HOME/projects/cart"
echo "---"
