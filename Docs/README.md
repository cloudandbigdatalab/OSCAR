# OCI OpenStack Ansible Guide

1. Proviosing the Bare Metal instances on Chameleon cloud 
2. Create key pair and add it the public key to all the nodes
3. Clone the repo and edit the inventory file
3. Install Ansible
4. Deploy OpenStack using OCI OpenStack Ansible

![Architecture](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide3.jpg "Architecture" )

OCI OpenStack Ansible project uses RPC for installation of OpenStack. Addition to RPC this project consists of scripts that prepare the hosts for the installation. This is a quick start guide for using this project.This guide helps the user to deploy OpenStack on 4 nodes, 1 controller node and 3 compute nodes.  

## Provising the Bare-Metal instances on Chameleon Cloud.

For provisioning the instances on Bare-Metal Cloud follow the guide from https://www.chameleoncloud.org/docs/bare-metal/ 

### Create a Key-pair and add Public key to all the nodes
Make sure that you are a root user and create a key pair on the controller node. We use this Key pair to grant the controller access to compute nodes and itself. 
```
 ssh-keygen -f .ssh/id_rsa -N ""  
```
This command generates a key pair (id_rsa and id_rsa.pub) in .ssh directory. The next step is to add the public key on all compute hosts and controller host. There are different ways of adding the Public key to authorized_keys of a host, using ssh-copy-id is one of them. If the public key from controller host has to be added into a autorized keys of root user on compute host type the following command.
```
ssh-copy-id root@<host ip>
```
Another way of dealing with this is just by opening and copying the content of id_rsa.pub into ~/.ssh/authorized_keys file on the host which needs to have access from the controller host. ssh into all the nodes, generate the key pair on controller node and add the public key to all the compute hosts and itself using the above described method.

< Needs some proper explaination or a step by step process instead of being all over the place like this >

### Clone the repo and edit the inventory file
OCI-OpenStack-Ansible repo has to be cloned into ```/opt/``` directory. Create ```/opt``` directory if it doesn't exists and change into that directory
```
mkdir /opt
cd /opt
```
Clone the github repo of OCI-OpenStack-Ansible and enter the OCI-OpenStack-Ansible directory
```
git clone https://github.com/UTSA-OCI/OCI-OpenStack-Ansible.git

cd OCI-OpenStack-Ansible
```
In this directory there is an ansible inventory file which should have the information of all the hosts. Open chameleon_cloud_nodes file with your favorite editor
```
nano chameleon_cloud_nodes
```
The file looks like this
```
[controller]
< controller ip >

[controller:vars]
controller_mgmt_ip="172.16.100.100"
compute1_mgmt_ip="172.16.100.101"
compute2_mgmt_ip="172.16.100.102"
compute3_mgmt_ip="172.16.100.103"
container_network="172.16.100.0/24"
tunnel_network="172.16.101.0/24"
storage_network="172.16.102.0/24"

[compute1]
< compute host 1 ip >

[compute1:vars]
compute_mgmt_ip="172.16.100.101"
compute_vxlan_ip="172.16.101.101"
compute_storage_ip="172.16.102.101"

[compute2]
< compute host 2 ip >

[compute2:vars]
compute_mgmt_ip="172.16.100.102"
compute_vxlan_ip="172.16.101.102"
compute_storage_ip="172.16.102.102"

[compute3]
< compute host 3 ip >

[compute3:vars]
compute_mgmt_ip="172.16.100.103"
compute_vxlan_ip="172.16.101.103"
compute_storage_ip="172.16.102.103"

[compute_nodes:children]
compute1
compute2
compute3
```
Add the ip address of controller and compute hosts at appropriate section as shown above and save the file.

### Installing Ansible
Ansible is required to deploy OpenStack using OCI-OpenStack-Ansible project. There is a bootstrap script available in /opt/OCI-OpenStack-Ansible/scripts directory which sets the ansible up for the user.
```
cd scripts
./bootstrap_ansible.sh
```

### Configuring the hosts for deployment using openstack-ansible
![Architecture](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide1.jpg "Architecture" )
The project comes with an set of ansible playbooks which can prep the controller and compute hosts environment for Openstack deployment using openstack-ansible. These playbooks also edit some configuration files from the original openstack-ansible project to make those scripts compatible with the environment created. Go ahead an run the following command from /opt/OCI-OpenStack-Ansible to start configuring the controller and compute hosts.
```
cd ..
ansible-playbook bootstrap-openstack-play.yml
```
The above command should have created clone openstack-ansible repo in /opt directory and changed some configuration files to suit the environment created.

### Deploying openstack using openstack-ansible 

```

```



