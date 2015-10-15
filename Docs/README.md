# OCI OpenStack Ansible Guide

1. Proviosing the Bare Metal instances on Chameleon cloud 
2. Create key pair and add it the public key to all the nodes
3. Clone the repo and edit the inventory file
3. Install Ansible
4. Deploy OpenStack using OCI OpenStack Ansible

OCI OpenStack Ansible project uses RPC for installation of OpenStack. Addition to RPC this project consists of scripts that prepare the hosts for the installation. This is a quick start guide for using this project.This guide helps the user to deploy OpenStack on 4 nodes, 1 controller node and 3 compute nodes.  

## Provising the Bare-Metal instances on Chameleon Cloud.

For provisioning the instances on Bare-Metal Cloud follow the guide from https://www.chameleoncloud.org/docs/bare-metal/ 

### Create a Key-pair and add Public key to all the nodes
Create a key pair on the controller node 
``` ssh-keygen ```
