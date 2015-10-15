#!/bin/bash
# This script runs everything necessary to set up a 4 node openstack cluster
# using the openstack-ansible project.

# Install ansible
pushd /opt/OCI-OpenStack-Ansible
  ./scripts/bootstrap-ansible.sh

# Copy over keys
echo "Have you copied over the keys from the controller to the compute node?"
exit
# Run bootstrap playbooks
  ansible-playbook bootstrap-openstack-plays.yml
popd

# Run openstack-ansible playbooks
pushd /opt/openstack-ansible/playbooks
  openstack-ansible setup-hosts.yml
  openstack-ansible haproxy-install.yml
  openstack-ansible setup-infrastructure.yml
  openstack-ansible setup-openstack.yml
popd
