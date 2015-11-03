

#### System requirements

We strongly recommand using Ubuntu 14.04 as operating system for the servers. Openstack deployment using this project is developed and tested for usage with Ubuntu 14.04.   

#### Provisioning a bare metal server using chameleon cloud 
 
 Chameleon cloud users may have to add an Ubuntu 14.04 image before they spin the servers. This process can be found here <Link for adding new bare metal image>. For additional informtion on usage of chameleon cloud please visit www.chameleoncloud.org.
 
#### Key pair authentication

OCI-OpenStack-Ansible and Openstack-ansible projects run based on ansible. For using ansible with the cluster the controller node has to have access to all the nodes along with itself. The access to the controller nodes can be granted using key pairs. Once the servers are up and running, create a key pair on controller node add the public key to authorized_keys of all the compute nodes and also controller node itself. Here are the set of instructions to do that.

Create a key pair on controller node. Make sure that you are logged in as **root** user while performing these steps.

```
 ssh-keygen -f .ssh/id_rsa -N ""  
```

This command should have created two files ``` id_rsa ``` and ``` id_rsa.pub ``` in ``` .ssh/ ``` folder. These files are called as a key-pair. ``` id_rsa ``` is called as private key and ``` id_rsa.pub ``` is called as a public key. Adding the public key into authorized_keys file can be done in two ways. It can be done by using ``` ssh-copy-id ``` or by manually adding it. If the servers can be accessed using password authentication use the following command.

```
ssh-copy-id root@<host ip>
```

Where host-ip should be replaced by ip address of all the servers including controller node itself.

In case Chameleon cloud password authentication is disabled by default, add the public key to authorized keys of all nodes manually by appending the contents of ``` id_rsa.pub``` to the ``` .ssh/authorized_keys ``` on all nodes along with the controller node. 

For example,

```
# Install xclip if not already installed
apt-get install xclip

# Copy contents of id_rsa.pub to clipboard
xclip -sel clip < ~/.ssh/id_rsa.pub
```

ssh to the node and change to root user, 


```
ssh userid@<node-ip>
sudo -i
```

Now, open the `~/.ssh/authorized_keys` file using nano or vim and add the copied contents from the clipboard, the public key, to the file and save it. Make sure this is done for all the nodes.

Check if all the nodes can be accessed using ``` ssh root@<node-ip> ``` command. Once controller node has access to all the nodes, the setup is ready for pre deployment procedures.


```
apt-get update
apt-get install git 
```
