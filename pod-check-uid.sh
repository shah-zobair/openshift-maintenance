#!/bin/bash


for PROJECT in `export KUBECONFIG=/etc/origin/master/admin.kubeconfig; oc login -u system:admin > /dev/null; oc get projects -o=custom-columns=NAME:.metadata.name | grep -E -v "^NAME$"`; do 

   oc project $PROJECT
   for POD in `oc get pod -n $PROJECT -o=custom-columns="NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase" | grep -E -v "build|deploy" | grep Running | awk {'print $1'}`; do

       oc rsh $POD id 
   done 

done
