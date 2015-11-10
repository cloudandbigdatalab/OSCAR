

Once the OSCAR setup is done, OpenStack should be up and running. The next important step would creating a virtual external network so that the VM's on top of our vDC can commounicate with outside world (Internet). For this we have pull a pool of IP's from chameleon shared net and add it to our virtual external network. Follow the steps shown below.

#### Requesting IP's from chameleon shared net

By default ```neutronclient``` should be installed on chameleon cloud nodes. If it is not installed, install it using pip

```
pip install python-neutronclient
```

From your project on Chalmeleon dashboard ***download the api access*** and ***save*** the contents to ```cc_openrc``` in the home directory of the controller node. These steps for requesting a pool of IP's from chameleon cloud can be executed from any machine, there is no restricition that this should be done from the contoller node itself. But Creating virtual external network for the OSCAR vDC should be done on chameleon cloud itself. 

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
lxc-ls



lxc-attach --name aio1_neutron_agents_container-128a859f

neutron net-create --provider:physical_network=flat --provider:network_type=flat --shared --router:external my_os_ext_net

neutron subnet-create my_os_ext_net 10.20.108.0/23 --name my_os_ext_subnet --gateway=10.20.109.254 --allocation-pool start=10.20.108.128,end=10.20.108.128 --allocation-pool start=10.20.108.129,end=10.20.108.129 --allocation-pool start=10.20.108.13,end=10.20.108.13


neutron router-create router1

neutron router-gateway-set router1 my_os_ext_net





