#!/usr/bin/env bash

##
## Reset to beginning of Developer Intro
## Desired State: monolith solution deployed in "coolstore-dev" project
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

# checkout solution and deploy to new project
git checkout solution
cd monolith
oc new-project coolstore-dev --display-name="Coolstore Monolith - Dev" || { echo "cant create project; ensure all projects gone with 'oc get projects' and try again"; exit 1; }
oc new-app coolstore-monolith-binary-build
mvn clean package -Popenshift
oc start-build coolstore --from-file=deployments/ROOT.war

# go back to master to start at the right place for scenario
mvn clean
git clean -df
git clean -Xf
git checkout master

# start in right directory
echo "---"
echo "Reset complete. To start in the right place: cd $HOME/projects/monolith"
echo "---"
