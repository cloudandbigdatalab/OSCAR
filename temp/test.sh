#!/bin/bash

#compute_count=1
#while IFS='' read -r line || [[ -n "$line" ]]; do
#   sed -i 's/.*compute_hosts:.*/&\n   compute'$compute_count':/' /etc/openstack_deploy/openstack_user_config.yml
#   sed -i 's/.*compute'$compute_count':.*/&\n      ip: '$line'/' /etc/openstack_deploy/openstack_user_config.yml
#   compute_count=$(($compute_count + 1))
#done < "/opt/OSCAR/management_ips"

# Count the lines after 'computes:' header in oscar.conf

#A=$(sed '1,/computes:/d;/^\s*$/d' /etc/oscar/oscar.conf | wc -l)

break_var=$(sed '1,/computes:/d;/- /d' /etc/oscar/oscar.conf | sed '1,/computes:/d;/- /d' /etc/oscar/oscar.conf | sed '1!d')

computes_count=$(sed "1,/computes:/d;/$break_var/,/^\s*$/d" /etc/oscar/oscar.conf | wc -l)

echo $computes_count

sed "1,/computes:/d;/$break_var/,/^\s*$/d" /etc/oscar/oscar.conf

management_ip="172.241.100.101"
management_ip_base=$(echo $management_ip | cut -d"." -f1-3)
echo $management_ip_base
for ((i=2; i<=computes_count+1; i++)); do
   line=$management_ip_base"."$(( 100 + $i ))
   compute_count=$(($i - 1))
   sed -i 's/.*compute_hosts:.*/&\n   compute'$compute_count':/' /etc/openstack_deploy/openstack_user_config.yml
   sed -i 's/.*compute'$compute_count':.*/&\n      ip: '$line'/' /etc/openstack_deploy/openstack_user_config.yml


   echo $management_ip_base"."$(( 100 + $i ))
done
