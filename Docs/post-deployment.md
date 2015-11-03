

### Post Deployment

#### Configure the public network using Neutron commands

Before moving on to Horizon dashboard there is one important thing that should be setup using CLI, creating a public network which helps user to acces the virtual machine. As explained in the previous chapters all the components run inside containers. A utility contianer can be user to configure this. From the controller node as root type in ```lxc-ls command```.

```
 lxc-ls 
```

This should display the list of all the servers running on the controller node similar to whats shown below.

```
aio1_cinder_api_container-c6f09cf7           
aio1_cinder_scheduler_container-d2ecf800     
aio1_galera_container-c1c57467               
aio1_glance_container-3991b4b2               
aio1_heat_apis_container-b8361739            
aio1_heat_engine_container-90278443          
aio1_horizon_container-d53946e9              
aio1_keystone_container-a99c8e4d             
aio1_memcached_container-bbef4d56            
aio1_neutron_agents_container-817a2152       
aio1_neutron_server_container-eee12c89       
aio1_nova_api_metadata_container-22bd112a    
aio1_nova_api_os_compute_container-6e0ba667  
aio1_nova_cert_container-ffcd9ac1            
aio1_nova_conductor_container-5863f6fb       
aio1_nova_console_container-afef93f9         
aio1_nova_scheduler_container-912e6d3b       
aio1_rabbit_mq_container-37fe30fa            
aio1_repo_container-3d452982                 
aio1_rsyslog_container-5ba93325              
aio1_utility_container-52c1aa7b
```
Log into the Utitlity container using ```lxc-attach --name <name of utility controller>```. Which is in our case

```
lxc-attach --name aio1_utility_container-52c1aa7b
```
This command should log the user into root of the utility container ```root@aio1_utility_container-52c1aa7b:~#```. To create a public network we are going to use ```neutron net-create``` and ```neutron subnet-create``` commands. The public network should be on the same network as the ```vm_gateway``` which can be configured from chameleon_cloud_nodes (ansible inventory file). The default value of ```vm_gateway``` is ```172.29.248.1```. So the public network we are going to create is ```172.29.248.1/24``` network. Use the following command to create a network named public_net

```
cd ~/
# export environment variables for username and password and other variables
source openrc
neutron net-create --provider:physical_network=flat --provider:network_type=flat --shared public_net --router:external
```
Create a subnet under public-net network. Provide network ip, gateway ip and allocation pool as arguments.

```
neutron subnet-create public_net 172.29.248.0/24 --name public_subnet --gateway=172.29.248.1 --allocation-pool start=172.29.248.4,end=172.29.248.250
```
This should setup the public network.

#### Login into Horizon dashboard

If the openstack installation is successful the horizon dashboard should be available online. Access the dashboard by using web browser and the url ```http://<controller Ip>```

The scripts should have already created an ```admin``` user with password ```openstack```, go ahead and login to the dashboard.

#### Setup a private network using horizon

Can be added from some other resource

#### Adding cloud image to Glance

#### Spinning up an instance

#### Accessing the instance



