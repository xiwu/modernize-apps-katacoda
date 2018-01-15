#!/usr/bin/env bash
echo "Running init commands" | tee ${HOME}/.init.log
if [ "$(oc whoami)" == "system:admin" ]; then
  echo "User is system:admin" | tee -a ${HOME}/.init.log

  oc adm policy add-role-to-user system:image-puller system:anonymous
  oc adm policy add-cluster-role-to-user cluster-admin admin
  oc import-image jenkins:v3.7 --from='registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7' --confirm -n openshift
  oc export template jenkins-persistent -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift
  oc export template jenkins-ephemeral -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift

  echo "Installing template" | tee -a ${HOME}/.init.log
  oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-binary.json
  oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-prod.json

  echo "Disable namespace ownership for router" | tee -a ${HOME}/.init.log
  oc env dc/router ROUTER_DISABLE_NAMESPACE_OWNERSHIP_CHECK=true -n default

  echo "Installing tree" | tee -a ${HOME}/.init.log
  yum install tree -y

  MASTER_EXTERNAL_URL=$(oc get route/docker-registry -n default | grep -v NAME | awk '{print $2}' | sed 's/docker\-registry\-default\.//' | sed 's/\-80\-/\-8443\-/')
  oc login $MASTER_EXTERNAL_URL -u developer -p developer --insecure-skip-tls-verify=true
  echo "Init was successful" | tee -a ${HOME}/.init.log

  docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7
  docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:latest
  docker pull nginx:latest

else
  echo "Skipping init since user is not system:admin anymore." | tee -a ${HOME}/.init.log
fi
find /root/rhamt-cli-4.0.0.Beta4 -name \*\._\* -print | xargs rm -f
git --git-dir=/root/projects/.git --work-tree=/root/projects pull