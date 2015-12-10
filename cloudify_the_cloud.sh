#!/bin/bash
# This script runs everything necessary to set up a 4 node openstack cluster
# using the openstack-ansible project.

# Install ansible
pushd /opt/openstack-ansible
  ./scripts/bootstrap-ansible.sh
popd

pushd /opt/OSCAR
# Run bootstrap playbooks
  ansible-playbook bootstrap-openstack-play.yml
popd

# Run openstack-ansible playbooks
pushd /opt/openstack-ansible/playbooks
  openstack-ansible setup-hosts.yml
  openstack-ansible haproxy-install.yml
  openstack-ansible setup-infrastructure.yml
  openstack-ansible setup-openstack.yml
popd
