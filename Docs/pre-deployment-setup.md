

### Pre-deployment setup



#### Cloning the git repository
OCI-OpenStack-Ansible has to be cloned into ```/opt/``` directory. Create ```/opt``` directory if it doesn't exists and change into that directory

```
mkdir /opt
cd /opt
```

Clone the github repo of OCI-OpenStack-Ansible and enter the OCI-OpenStack-Ansible directory

```
git clone https://github.com/cloudandbigdatalab/OSCAR.git

cd OCI-OpenStack-Ansible
```

#### Installing Ansible 

Ansible is required to deploy OpenStack using OCI-OpenStack-Ansible project. There is a bootstrap script available in /opt/OCI-OpenStack-Ansible/scripts directory which sets the ansible up for the user.
```
cd scripts
./bootstrap_ansible.sh
```

#### Configuring the Ansible inventory file

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

#### Preparing the environment for OpenStack deployment

![Architecture](https://github.com/UTSA-OCI/OCI-OpenStack-Ansible/blob/master/Docs/Figures/Slide1.jpg "Architecture" )
The project comes with an set of ansible playbooks which can prep the controller and compute hosts environment for Openstack deployment using openstack-ansible. These playbooks also edit some configuration files from the original openstack-ansible project to make those scripts compatible with the environment created. Go ahead an run the following command from /opt/OCI-OpenStack-Ansible to start configuring the controller and compute hosts.
```
cd ..
ansible-playbook bootstrap-openstack-play.yml
```
The above command should have cloned openstack-ansible repo in /opt directory and changed some configuration files to suit the environment created.


