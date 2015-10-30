# OpenStack Configurator for Academic Research (OSCAR)

### Introduction

OpenStack is the open source software for creating public and private clouds. OpenStack software controls large pools of compute, storage, and networking resources throughout a datacenter, managed through a dashboard or via the OpenStack API. OpenStack works with popular enterprise and open source technologies making it ideal for heterogeneous infrastructure \[[1]\].

OpenStack has a modular architecture with various code names for its components. Compute (cloud fabric controller - Nova), image service (Glance), dashboard (Horizon), networking (Neutron), block storage (Cinder), object storage (Swift) and identity service (Keystone) are some important components. OpenStack can be setup with mix and match of different components. Several organizations have their own configuations for installing OpenStack, OpenStack-Ansible is one of them. OpenStack-Ansible is an official OpenStack project which aims to deploy production environments from source in a way that makes it scalable while also being simple to operate, upgrade, and grow \[[2]\].

OpenStack setup in multi-node configuration is non trivial and requires proper configuration of computing resources. In academia provisioning these resources is arduous. Due to this complex nature of OpenStack installation academic research in this field has not advanced. 

The OSCAR project is designed to simplify the configuration of resources and OpenStack installation process. This project has scripts to configure the computing resources and prepare them for OpenStack deployment using OpenStack-Ansible, an official OpenStack project. This package also pulls stable version of the OpenStack-Ansible from github and edits the configuration files to match the configured environment.

### Overview

![Components of cluster](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide6.jpg "Components of cluster" )

This guide gives a walk through OpenStack deployment on 5 nodes cluster (1 Controller node and 4 Compute nodes). The Controller and Compute nodes will have different components installed in them as shown in figure. 

***Controller node:*** As the name suggests, this node controls the OpenStack cluster. This contains all the important components for proper functioning of the OpenStack cluster. Components like identity service, image service, networking and compute are installed in this node.

***Compute node:*** The virtual machines are hosted in these nodes. The compute service, hypervisor and network agents are installed in this node. 

![Components of cluster](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide4.jpg "Components of cluster" )

The deployment process is 4 fold as mentioned below. 

- Servers setup 
- Pre deployment 
- OpenStack deployment 
- Post deployment 







<!--

- Servers setup and requirements
- Pre deployment instructions
- OpenStack deployment 
- Post deployment instructions

-->





[1]: https://www.openstack.org
[2]: https://github.com/openstack/openstack-ansible
