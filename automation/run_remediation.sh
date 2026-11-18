#!/bin/bash
INSTANCE="${1%%:*}"; ACTION="$2"
LOG=/var/log/soc-remediation.log
case "$INSTANCE" in 10.10.10.21|10.10.10.22) ;; *) echo "$(date -Is) REJECTED host $INSTANCE" >> $LOG; exit 1;; esac
[ "$ACTION" = "disk_cleanup" ] || { echo "$(date -Is) REJECTED action $ACTION" >> $LOG; exit 1; }
echo "$(date -Is) START $ACTION on $INSTANCE" >> $LOG
if ansible-playbook -i /opt/soc/automation/inventory.ini /opt/soc/automation/disk_cleanup.yml -e target=$INSTANCE >> $LOG 2>&1
then echo "$(date -Is) OK $ACTION on $INSTANCE" >> $LOG
else echo "$(date -Is) FAILED $ACTION on $INSTANCE" >> $LOG; fi
