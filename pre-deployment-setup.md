---
layout: page
title: Introduction and Overview
permalink: /pre-deployment/
---

### Pre-deployment setup

```
apt-get update
apt-get install git
```

#### Cloning the git repository
OCI-OpenStack-Ansible has to be cloned into ```/opt/``` directory. Create ```/opt``` directory if it doesn't exists and change into that directory

```
mkdir /opt
cd /opt
```

Clone the github repo of OSCAR and enter the OSCAR directory

```
git clone https://github.com/cloudandbigdatalab/OSCAR.git

cd OSCAR
```

#### Configuring the OSCAR config file

Create ```/etc/oscar``` folder and copy ```oscar.conf.example``` to this folder as ```oscar.conf```

```
mkdir /etc/oscar

cp /opt/OSCAR/oscar.conf.example /etc/oscar/oscar.conf
```

In this directory there is an config which should have the information of all the hosts. Open oscar.conf file with your favorite editor
```
nano /etc/oscar/oscar.conf
```
The file looks like this
```
network:
  container_network: 172.17.100.0/24
  tunnel_network: 172.17.101.0/24
  storage_network: 172.17.102.0/24
  vm_gateway: 172.17.248.1

nodes:
  controller: 10.20.109.72
  computes:
    - 10.20.109.78
    - 10.20.109.79
    - 10.20.109.80

```
Add the ip address of controller and compute hosts at appropriate section as shown above and save the file.

#### Installing Ansible 

Ansible is required to deploy OpenStack using OSCAR project. There is a bootstrap script available in /opt/OSCAR/scripts directory which sets the ansible up for the user.
```
cd /opt/OSCAR/scripts
./bootstrap-ansible.sh

```

#### Preparing the environment for OpenStack deployment

<!--![Architecture](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide1.jpg "Architecture" )-->
<img src="https://github.com/cloudandbigdatalab/OSCAR/blob/gh-pages/assets/figures/Slide6.jpg?raw=True" width="100%">

The project comes with an set of ansible playbooks which can prep the controller and compute hosts environment for Openstack deployment using openstack-ansible. These playbooks also edit some configuration files from the original openstack-ansible project to make those scripts compatible with the environment created. Go ahead an run the following command from /opt/OSCAR to start configuring the controller and compute hosts.
```
cd /opt/OSCAR
ansible-playbook bootstrap-openstack-play.yml
```
The above command should have cloned openstack-ansible repo in /opt directory and changed some configuration files to suit the environment created.


