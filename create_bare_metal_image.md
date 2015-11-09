Login into your Chameleon cloud project page (https://chi.tacc.chameleoncloud.org)

Project > Access & Security > OpenStack RC file

This should allow you to download OpenStack RC file

## Source the downloaded OpenStack RC script

Make sure that you are a root user

Copy it to the Centos machine and run the script

``` 
source <filename>.sh
```

This adds all the necessary credentials as environment variables.


## Install the neccessary packages

``` 
yum install git libguestfs-tools-c 

or 

sudo apt-get install libguestfs-tools
```

``` 
git clone https://github.com/openstack/diskimage-builder.git 
```

## Download the image from Ubuntu or Centos website (qcow2 format)

```
Ubuntu 14.04.03 image
wget http://uec-images.ubuntu.com/releases/14.04/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img

Centos7 image
  wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-20141129_01.qcow2c
```  
## Follow these steps for creating the image

``` 
export DIB_LOCAL_IMAGE=~/<Downloaded-image-path> 
```
  
<image type> implies ubuntu or centos7  

``` 
diskimage-builder/bin/disk-image-create <image type> baremetal -o <Custom name>
```
  
for example to create a ubuntu image

``` 
diskimage-builder/bin/disk-image-create ubuntu baremetal -o Ubuntu_14_04
```

``` 
glance image-create --name <Custom name>-kernel --is-public False --progress --disk-format aki < <Custom name>.vmlinuz
```  
  
After this command a catalog is displayed and copy the id from the catalog and export it to VMLINUZ_UUID 

```
export VMLINUZ_UUID=<Id from catalog>
```

```
  glance image-create --name <Custom name>-initrd --is-public False --progress --disk-format ari < <Custom name>.initrd
```

After this command a catalog is displayed and copy the id from the catalog and export it to INITRD_UUID

```
export INITRD_UUID=<Id from catalog>  
```
```
  glance image-create --name CC-CentOS7 --is-public True --disk-format qcow2 --container-format bare --property kernel_id=$VMLINUZ_UUID --property ramdisk_id=$INITRD_UUID < CC-CentOS7.qcow2  
```
