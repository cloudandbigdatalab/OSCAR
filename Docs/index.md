# Openstack Ansible installation guide

## Introduction

OpenStack is the open source software for creating public and private clouds. OpenStack software controls large pools of compute, storage, and networking resources throughout a datacenter, managed through a dashboard or via the OpenStack API. OpenStack works with popular enterprise and open source technologies making it ideal for heterogeneous infrastructure \[[1]\].

OpenStack has a modular architecture with various code names for its components. Compute (cloud fabric controller), image service, dashboard, networking, block storage and identity serive are some important components. OpenStack can be setup with mix and match of different components. Several organizations have their own configuations for installing OpenStack, OpenStack-Ansible is one of them. OpenStack-Ansible is an official OpenStack project which aims to deploy production environments from source in a way that makes it scalable while also being simple to operate, upgrade, and grow \[[2]\].

OpenStack setup in multi node configuation is non trivial and requires proper configuration of computing resources. In academia provisioning these resources is arduous. Due to this complex nature of OpenStack installtion academic research in this field has not advanced. 

The OCI-OpenStack-Ansible project is intended to simlify the configuration of resources and OpenStack installation process. This project has scripts to configre the computing resources and prepare them for OpenStack deployment using OpenStack-Ansible, an official OpenStack project.

- Server setup and requirements
- Pre deployment instructions
- OpenStack deployment 
- Post deployment instructions










[1]: https://www.openstack.org
[2]: https://github.com/openstack/openstack-ansible
