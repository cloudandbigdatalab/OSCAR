# OSCAR

## Overview
Work in progress

## Quick Start
Work in progress

## Process
This project is envisioned to be one, all-inclusive ansible playbook
that runs a set of bash scripts (which can be converted to ansible plays)
and ansible roles. The whole process can be broken down to something
like:

0. Pre-req: Provision the Bare metal nodes necessary on the Chameleon Cloud. Curretly
   this project supports 1 controller node, and 3 computes. This is the absolute
   requirement.

1. Configure the controller with the appropriate network, openstack-ansible,
   and package configurations. An ansible role can be created that will run
   the bootstrap-controller.sh script, which will in turn perform these actions.

2. Configure the compute nodes with the appropriate network and package
   configurations. An ansible role can be created that will run the bootstrap-
   compute.sh script, which will in turn perform these actions.

3. Run an intermiddiate plays or roles that are used for any actions that might
   be performed before openstack is deployed. e.g. verify network connectivity,
   packages, and network interfaces are up.

4. Run the openstack-ansible playbooks

Work in progress..


## Technical Considerations

* How can we run the openstack-ansible playbooks from the OCI-Openstack-Ansible
  playbooks? We need to make this process seamless and fluid.
