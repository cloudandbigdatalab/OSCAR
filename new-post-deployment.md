---
layout: page
title: Post Deployment
permalink: /post-deployment/
divlink: post-deployment
postdeployment: class="active"

---

Once the OSCAR setup is done, OpenStack should be up and running. The next important step would creating a virtual external network so that the VM's on top of our vDC can commounicate with outside world (Internet). For this we have pull a pool of IP's from chameleon shared net and add it to our virtual external network. Follow the steps shown below.

#### Requesting IP's from chameleon shared net

By default ```neutronclient``` should be installed on chameleon cloud nodes. If it is not installed, install it using pip

```
pip install python-neutronclient
```

From your project on Chalmeleon dashboard **download the api access** and **save** the contents to ```cc_openrc``` in the home directory of the controller node. These steps for requesting a pool of IP's from chameleon cloud can be executed from any machine, there is no restricition that this should be done from the contoller node itself. But Creating virtual external network for the OSCAR vDC should be done on chameleon cloud itself.

Source cc_openrc file and enter your chameleon account password. This file exports all credentials requeired for communicating with chameleon cloud as environmental variables and the following commands use these environment variables while talking to chameleon cloud.

```
# Make sure you read the above two paragraphs and
# downloaded the required contents before proceeding forward.
source cc_openrc
```

Check to see if chameleon cloud is reponding for your neutron-clint commands. The following command gives a list for networs available on chamleon cloud.

```
neutron net-list
```

If something similar to this is displayed then the neutron-client is working fine. If it is not please visit back the ```source cc_openrc``` step and make sure password you provided is right

```
+---------------------+------------+-------------------------------+
| id                  | name       | subnets                       |
+---------------------+------------+-------------------------------+
| <network uuid>      | sharednet1 | <sub-net uuid> 10.20.108.0/23 |
| <network uuid>      | ext-net    | <sub-net uuid>                |
+---------------------+------------+-------------------------------+
```

Now request chameleon cloud for a pool of IP's. The following step requests 3 IP's

```
neutron port-create sharednet1

neutron port-create sharednet1

neutron port-create sharednet1
```

When you type in ```neutron port-create sharednet1``` you should see an output something similar to this

```
Created a new port:
+-----------------------+---------------------------------------------------------------+
| Field                 | Value                                                         |
+-----------------------+---------------------------------------------------------------+
| admin_state_up        | True                                                          |
| allowed_address_pairs |                                                               |
| binding:vnic_type     | normal                                                        |
| device_id             |                                                               |
| device_owner          |                                                               |
| fixed_ips             | {"subnet_id": "<sub-net uuid>", "ip_address": "10.20.109.33"} |
| id                    | <some uuid>                                                   |
| mac_address           | < mac_address of the port>                                    |
| name                  |                                                               |
| network_id            | <network uuid>                                                |
| security_groups       | <security group related uuid>                                 |
| status                | DOWN                                                          |
| tenant_id             | <project name>                                                |
+-----------------------+---------------------------------------------------------------+
```

Save the IP address from these messages and we will be using these IP addresses in coming steps.

Unset the following environment variables if you are doing this process on controller because, we are about to source openrc for our OSCAR vDC and our OSCAR vDC doesn't have TENANT_ID and REGION_NAME parameters so when we source it, the commands assumes that these two are available on our vDC and gives us an error

```
unset OS_TENANT_ID
unset OS_REGION_NAME
```


#### Creating virtual external network for the OSCAR vDC

The following steps would guide you in creating an virtual external network for OSCAR vDC. **List the containers running on the controller node and attach to the neutron agents container**.

```
# List the containers
lxc-ls
```

In our case name of  **neutron agents container** was **aio1_neutron_agents_container-128a859f** so to attach to the container we used

```
lxc-attach --name aio1_neutron_agents_container-128a859f
```

Now to create an external virtual network with name **v-ext-net** use the following command

```
neutron net-create --provider:physical_network=flat --provider:network_type=flat --shared --router:external v-ext-net
```

Now use the following command to create a sub-net for **v-ext-net** with name **v-ext-sub-net** and add the allocation pool of IP's gathered in the intial steps. If the IP's gathered are in in order say ```10.xx.xx.10, 10.xx.xx.11, 10.xx.xx.12``` then in the command directly use ```--allocation-pool start=10.xx.xx.10,end=10.xx.xx.12``` if the gathered IP's are not in order then different allocation pools with same start and end IP's should be used. The command below uses different allocation pools which means the gathered IP's are not in order.

```
neutron subnet-create v-ext-net 10.20.108.0/23 --name v-ext-sub-net --gateway=10.20.109.254 --allocation-pool start=10.xx.xx.11,end=10.xx.xx.11 --allocation-pool start=10.xx.xx.13,end=10.xx.xx.13 --allocation-pool start=10.xx.xx.15,end=10.xx.xx.15
```

Finally create a router and interface it with v-ext-net

```
neutron router-create v-router

neutron router-gateway-set v-router v-ext-net
```

The virtual external network is setup. The next steps would be to setup a private network using horizon, interfacing it with ```v-router``` and spinning an instance on private network.

To create internal network

```
neutron net-create --provider:network_type=vxlan --shared internal_net
neutron subnet-create internal_net 192.168.1.0/16 --name internal_subnet --dns-nameservers list=true 8.8.8.8 
```
