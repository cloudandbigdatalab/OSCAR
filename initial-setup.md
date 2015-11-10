---
layout: page
title: Initial setup and requirements
permalink: /initial-setup/
---

#### System requirements

We strongly recommend using Ubuntu 14.04 as operating system for the servers. Openstack deployment using this project is developed and tested for usage with Ubuntu 14.04.   

#### Provisioning a bare metal server using chameleon cloud 
 
 Chameleon cloud users may have to add an Ubuntu 14.04 image before they spin the servers. This process can be found here <Link for adding a new bare metal image>. For additional informtion on usage of chameleon cloud please visit www.chameleoncloud.org.
 
#### Key pair authentication

OSCAR and OpenStack-ansible projects run based on ansible. For using ansible with the cluster the controller node has to have access to all the nodes along with itself. The access to the controller nodes can be granted using key pairs. Once the servers are up and running, create a key pair on controller node add the public key to authorized_keys of all the ***all nodes along with controller node itself***. Here are the set of instructions to do that.

Create a key pair on controller node. Make sure that you are logged in as root user while performing these steps.

```
 ssh-keygen -f .ssh/id_rsa -N ""  
```

This command should have created two files ``` id_rsa ``` and ``` id_rsa.pub ``` in ``` .ssh/ ``` folder. These files are called as a key-pair. ``` id_rsa ``` is called as private key and ``` id_rsa.pub ``` is called as a public key.

##### Adding the public keys to the authorized_keys of root user on all nodes including controller node

Adding the public key into authorized_keys file can be done in two ways. 

   - Using ``` ssh-copy-id ``` 

   - Manually adding the public key 

##### Using ``` ssh-copy-id ``` 
This method is simple and works fine when the root user of the nodes can be accessed using password. Use the following command

```
ssh-copy-id root@<host ip>
```

Where host-ip should be replaced by ip address of all the servers including controller node itself.

##### Manually adding the public key
In case of Chameleon cloud, password authentication is disabled by default. And if you can access the root user on the node only using private key then follow this method. 

On your controller node open the open ``` ~/.ssh/id_rsa.pub ```

```
cat ~/.ssh/id_rsa.pub
```

ssh to the node and change to root user, 

```
ssh userid@<node-ip>
sudo -i
```

Now, open the `~/.ssh/authorized_keys` file using nano or vim and add the copied contents,the public key, to the file and save it. Make sure this is done for all the nodes.



Check if all the nodes can be accessed using ``` ssh root@<node-ip> ``` command. Once controller node has access to all the nodes, the setup is ready for pre deployment procedures.

#### Update and Install git 
Its time to clone OSCAR repo, lets update the apt-packages lists and install git 

```
apt-get update
apt-get install git -y
```
