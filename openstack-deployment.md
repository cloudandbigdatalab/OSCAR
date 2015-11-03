---
layout: page
title: Introduction and Overview
permalink: /openstack-deployment/
---

### OpenStack deployment using OpenStack-Ansible project scripts.

Once the network configuration of the controller and compute hosts is properly done, deploying openstack using openstack-ansible is very simple. Follow the commands below.

```
cd /opt/openstack-ansible/playbooks
openstack-ansible setup-hosts.yml
openstack-ansible haproxy-install.yml
openstack-ansible setup-infrastructure.yml 
```

#### Keystone installation
Keystone is an OpenStack project that provides Identity, Token, Catalog and Policy services for use specifically by projects in the OpenStack family. It implements OpenStack’s Identity API \[[1]\].

``` 
openstack-ansible os-keystone-install.yml
```

#### Glance installation
The Glance project provides a service where users can upload and discover data assets that are meant to be used with other services. This currently includes images and metadata definitions.

Glance image services include discovering, registering, and retrieving virtual machine images. Glance has a RESTful API that allows querying of VM image metadata as well as retrieval of the actual image \[[2]\].

``` 
openstack-ansible os-glance-install.yml
```

#### Cinder installation
Cinder is a Block Storage service for OpenStack. It's designed to allow the use of either a reference implementation (LVM) to present storage resources to end users that can be consumed by the OpenStack Compute Project (Nova). The short description of Cinder is that it virtualizes pools of block storage devices and provides end users with a self service API to request and consume those resources without requiring any knowledge of where their storage is actually deployed or on what type of device \[[3]\].

``` 
openstack-ansible os-cinder-install.yml
```

#### Nova installation
Nova is an OpenStack project designed to provide power massively scalable, on demand, self service access to compute resources \[[4]\].

``` 
openstack-ansible os-nova-install.yml
```

#### Neutron installation
OpenStack Neutron is an SDN networking project focused on delivering networking-as-a-service (NaaS) in virtual compute environments. Neutron has replaced the original networking application program interface (API), called Quantum, in OpenStack. Neutron is designed to address deficiencies in “baked-in” networking technology found in cloud environments, as well as the lack of tenant control in multi-tenant environments over the network topology and addressing, which makes it hard to deploy advanced networking services \[[5]\].

``` 
openstack-ansible os-neutron-install.yml
```

#### Heat installation
Heat is the main project in the OpenStack Orchestration program. It implements an orchestration engine to launch multiple composite cloud applications based on templates in the form of text files that can be treated like code. A native Heat template format is evolving, but Heat also endeavours to provide compatibility with the AWS CloudFormation template format, so that many existing CloudFormation templates can be launched on OpenStack. Heat provides both an OpenStack-native ReST API and a CloudFormation-compatible Query API \[[6]\].

``` 
openstack-ansible os-heat-install.yml
```

#### Horizon installation
Horizon is the canonical implementation of OpenStack’s Dashboard, which provides a web based user interface to OpenStack services including Nova, Swift, Keystone, etc \[[7]\].

``` 
openstack-ansible os-horizon-install.yml
```

### Congratulations you have built an OpenStack Cloud
Now go ahead and access the horizon dashboard from any internet browser ```http://<Controller-IP>``` . For example

```
http://120.11.1.10
```
OpenStack is setup up successfully if horizon dashboard is accesable. Although OpenStack is up and running network is not setup yet. Different instructions are provided in the documentation for creating different network configurations. 

***Documentation in progress for Network config***

<!--
#### Ceilometer installation
The Ceilometer project aims to deliver a unique point of contact for billing systems to acquire all of the measurements they need to establish customer billing, across all current OpenStack core components with work underway to support future OpenStack components \[[8]\].

``` 
openstack-ansible os-ceilometer-install.yml
```

#### Aodh installation
Aodh is the alarm engine of the Ceilometer project

``` 
openstack-ansible os-aodh-install.yml
```

#### Swift installation
Swift is a highly available, distributed, eventually consistent object/blob store. Organizations can use Swift to store lots of data efficiently, safely, and cheaply \[[9]\].

``` 
openstack-ansible os-swift-install.yml
```
-->


[1]: http://docs.openstack.org/developer/keystone/
[2]: http://docs.openstack.org/developer/glance/
[3]: https://wiki.openstack.org/wiki/Cinder
[4]: http://docs.openstack.org/developer/nova/
[5]: https://www.sdxcentral.com/resources/open-source/what-is-openstack-quantum-neutron/
[6]: https://wiki.openstack.org/wiki/Heat
[7]: http://docs.openstack.org/developer/horizon/
[8]: http://docs.openstack.org/developer/ceilometer/
[9]: http://docs.openstack.org/developer/swift/

