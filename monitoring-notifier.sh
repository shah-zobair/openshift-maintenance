#!/bin/bash

# This script needs to be run for every 10 minutes or lesser as it checks last 10 Error entries only. 

LOG_FILE=/var/log/openshift_monitoring.log
CURRENT_DATE=`date +"%d%m%y"`


if [[ ! -f $LOG_FILE ]];then
# openshift-monitoring is not running or the log is stored in a different location. Exiting with Code 0
exit 0
fi

if [[ ! -f /root/monitoring-notifier-counter ]];then
   echo "$CURRENT_DATE 0" > /root/monitoring-notifier-counter
elif [[ -z "$CURRENT_DATE" ]];then
   echo "$CURRENT_DATE 0" > /root/monitoring-notifier-counter
fi

ERROR_COUNT=`tail $LOG_FILE | grep -i ERROR | wc -l`

if [[ $ERROR_COUNT -gt 0 ]]; then
   ERROR_DATE=`date +"%d%m%y"`
   LAST_COUNTER=`cat /root/monitoring-notifier-counter | awk '{ print $2 }'`
   COUNTER=`expr $LAST_COUNTER + 1`
   echo "$CURRENT_DATE $COUNTER" > /root/monitoring-notifier-counter

   if [[ $COUNTER -ge "0" && $COUNTER -le "1" ]]; then
      echo "`date`: Error is observerd on `hostname` for $ERROR_COUNT consecutive times (First counter)"
   elif [[ $COUNTER -ge "5" && $COUNTER -le "5" ]]; then
      echo "`date`: Error is observerd on `hostname` for $ERROR_COUNT consecutive times(Second counter)"
   elif [[ $COUNTER -ge "10" && $COUNTER -le "10" ]]; then
      echo "`date`: Error is observerd on `hostname` for $ERROR_COUNT consecutive times(Third counter). No further notification will be generated for today"
   else
      exit 0
   fi
fi

