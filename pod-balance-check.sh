#!/bin/bash


for PROJECT in `export KUBECONFIG=/etc/origin/master/admin.kubeconfig; oc login -u system:admin > /dev/null; oc get projects -o=custom-columns=NAME:.metadata.name | grep -E -v "^NAME$|^default$|^openshift$|^openshift-infra$|^management-infra$|^logging$|^kube-|^prometheus"`; do 

   #echo $PROJECT
   oc get dc -n $PROJECT -o=custom-columns="NAME:.metadata.name,REPLICA:.status.availableReplicas" | grep -v ^NAME | awk {'print $1'} > /tmp/dc_list
   oc get pod -n $PROJECT -o=custom-columns="NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase" | grep -E -v "build|deploy" | grep Running | awk {'print $1,$2'} > /tmp/pod_list

   while read dc; do
     POD_COUNT=`grep ^$dc /tmp/pod_list | wc -l`
     NODE_COUNT=`grep ^$dc /tmp/pod_list | awk {'print $2'} | uniq | wc -l`
     if [[ $POD_COUNT == $NODE_COUNT ]]; then
       echo "OK Namespace: $PROJECT DC: $dc"
     else
       echo ""
       echo "#########"
       echo "Pod/s are not balanced in PROJECT: $PROJECT and DC: $dc"
       cat /tmp/pod_list
     fi
   done < /tmp/dc_list

done
