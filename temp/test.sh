#!/bin/bash

compute_count=1
while IFS='' read -r line || [[ -n "$line" ]]; do
   sed -i 's/.*compute_hosts:.*/&\n   compute'$compute_count':/' /etc/openstack_deploy/openstack_user_config.yml
   sed -i 's/.*compute'$compute_count':.*/&\n      ip: '$line'/' /etc/openstack_deploy/openstack_user_config.yml
   compute_count=$(($compute_count + 1))
done < "/opt/OSCAR/management_ips"


