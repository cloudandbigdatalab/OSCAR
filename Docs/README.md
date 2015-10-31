# OpenStack Configurator for Academic Research (OSCAR) Guide

1. Provisioning the Bare-Metal instances on Chameleon cloud 
2. Create key-pair and add it the public-key to all the nodes
3. Clone the repository and edit the inventory file
3. Install Ansible
4. Deploy OpenStack using OSCAR project
5. Accessing Horizon dashboard and adding image

![Architecture](https://github.com/cloudandbigdatalab/OSCAR/blob/master/Docs/Figures/Slide3.jpg "Architecture" )

OCI OpenStack Ansible project uses Openstack Ansible Deployment(OSD) for the installation of OpenStack. In addition to OSD, this project consists of scripts that prepare the hosts for the installation. This is a quick start guide for using this project.This guide helps the user to deploy OpenStack on 4 nodes, 1 controller node and 3 compute nodes.  

## Provisioning the Bare-Metal instances on Chameleon Cloud.

For provisioning the instances on Bare-Metal cloud follow the guide from https://www.chameleoncloud.org/docs/bare-metal/ 

### Create a key-pair and add public key to all the nodes
Make sure that you are a root user and create a key-pair on the controller node. We use this key-pair to grant the controller access to compute nodes and itself. 
```
 ssh-keygen -f .ssh/id_rsa -N ""  
```
This command generates a key-pair (id_rsa and id_rsa.pub) in .ssh directory. The next step is to add the public key on all compute hosts and controller host. There are different ways of adding the public key to authorized_keys of a host, using ssh-copy-id is one of them. If the public key from controller host has to be added into a authorized keys of root user on compute host type the following command.
```
ssh-copy-id root@<host ip>
```
Another way of dealing with this is just by opening and copying the content of id_rsa.pub into ~/.ssh/authorized_keys file on the host which needs to have access from the controller host. ssh into all the nodes, generate the key-pair on controller node and add the public key to all the compute hosts and itself using the above described method.

< Needs some proper explaination or a step by step process instead of being all over the place like this >

### Pre-deployment setup
```
apt-get update
apt-get install git
```

### Clone the repo and edit the inventory file
OSCAR repo has to be cloned into ```/opt/``` directory. Create ```/opt``` directory if it doesn't exists and change into that directory
```
mkdir /opt
cd /opt
```
Clone the github repo of OSCAR and enter the OSCAR directory
```
git clone https://github.com/cloudandbigdatalab/OSCAR.git

cd OSCAR
```
### Configuring the OSCAR config file
Create /etc/oscar folder and copy oscar.conf.example to this folder as oscar.conf
```
mkdir /etc/oscar

cp /opt/OSCAR/oscar.conf.example /etc/oscar/oscar.conf
```
In this directory there is a config which should have the information of all the hosts. Open oscar.conf file with your favorite editor
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

### Installing Ansible
Ansible is required to deploy OpenStack using OSCAR project. There is a bootstrap script available in /opt/OSCAR/scripts directory which sets the ansible up for the user.
```
cd scripts
./bootstrap-ansible.sh
``

### Configuring the hosts for deployment using openstack-ansible
![Architecture](https://github.com/cloudandbigdatalab/OSCAR/blob/master/Docs/Figures/Slide1.jpg "Architecture" )
The project comes with an set of ansible playbooks which can prep the controller and compute hosts environment for OpenStack deployment using OpenStack-Ansible. These playbooks also edit some configuration files from the original OpenStack-Ansible project to make those scripts compatible with the environment created. Go ahead an run the following command from /opt/OSCAR to start configuring the controller and compute hosts.
```
cd /opt/OSCAR
ansible-playbook bootstrap-openstack-play.yml
```
The above command should have created clone openstack-ansible repo in /opt directory and changed some configuration files to suit the environment created.

### Deploying openstack using openstack-ansible 
Once the network configuration of the controller and compute hosts is properly done, deploying openstack using openstack-ansible is very simple. Follow the commands below.

```
cd ../openstack-ansible/playbooks
openstack-ansible setup-hosts.yml
openstack-ansible haproxy-install.yml
openstack-ansible setup-infrastructure.yml 
openstack-ansible setup-openstack.yml 
```
### Accessing Horizon dashboard and adding image
If the openstack installation is successful the horizon dashboard should be available online. Acces the dashboard by using web browser and the url ```http://<controller Ip>```



