# 1. Ubuntu 14.04

### Creating Ubuntu 14.04 Image using CLI to your OpenStack Cloud

### Step 1: Logon to your server

```
ssh username@<ip address>
```

### Step 2: Switch as a root user

```
sudo -i
```

### Step 3: Setting the environment variables (as a admin/root)

```
source openrc
``` 

### Step 4: Check for list of images already created

```
glance image-list
```

### Step 5:  Create a directory named images inside the var directory to store all the images you download.

```
mkdir /var/images/
```

### Step 5: Below command will download the required Ubuntu 14.04 image from the internet to the ```/var/images/``` location

```
wget http://uec-images.ubuntu.com/releases/14.04/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img -P /var/images/
```

### Step 6: Once downloaded, use this image and create a Ubuntu 14.04 image in glance

```
glance image-create --name="Ubuntu 14.04" --is-public=true --disk-format=qcow2 --container-format=bare < /var/images/ubuntu-14.04-server-cloudimg-amd64-disk1.img

```

### Step 7: Finally, check if the image is being created

```
glance image-list
```

# 2. CentOS7

## Creating a CentOS7 Image using CLI to your OpenStack cloud

### Step 1: Logon to your server

```
ssh username@<ip address>
```

### Step 2: Switch as a root user

```
sudo -i
```

### Step 3: Setting the environment variables (as a admin/root)

```
source openrc
``` 

### Step 4: Check for list of images already created

```
glance image-list
```

### Step 5:  create a directory named images inside the var directory to store all the images you download.

```
mkdir /var/images/
```

### Step 6: Below command will download the required centOS7 image from the internet to the ```/var/images/``` location

```
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-20141129_01.qcow2c -P /var/images/
```

### Step 7: Once downloaded, use this image and create a CentOS7 image in glance

```
 glance image-create --name="CentOS7" --is-public=true --disk-format=qcow2 --container-format=bare < /var/images/CentOS-7-x86_64-GenericCloud-20141129_01.qcow2c
```

### Step 8: Finally, check if the image is being created

```
glance image-list
```

# 3. CoreOS 766.5.0

## Creating CoreOS 766.5.0 Image using CLI to your OpenStack Cloud

### Step 1: Logon to your server

```
ssh username@<ip address>
```

### Step 2: Switch as a root user

```
sudo -i
```

### Step 3: Setting the environment variables (as a admin/root)

```
source openrc
``` 

### Step 4: Check for list of vm images already created

```
glance image-list
```

### Step 5: Create a directory named images inside the var directory to store all the images you download.

```
mkdir /var/images/
```

### Step 6: Download the image

```
 wget http://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2 -P /var/images/
```

### Step 7: The above downloaded CoreOS image is a zip file to unzip it go inside the ```/var/images/``` location

```
cd /var/images/
```

### Step 8: Use the following command to unzip the image

```
bunzip2 coreos_production_openstack_image.img.bz2
```

### Step 9: Run the following ```glance``` command to create an  CoreOS image: 

```
glance image-create --name="CoreOS" --is-public=true --disk-format=qcow2 --container-format=bare < /var/images/coreos_production_openstack_image.img 
```

### Step 10: Finally, check if the image is being created

```
glance image-list
```
