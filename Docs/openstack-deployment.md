

### OpenStack deployment using OpenStack-Ansible project scripts.

Once the network configuration of the controller and compute hosts is properly done, deploying openstack using openstack-ansible is very simple. Follow the commands below.

```
cd ../openstack-ansible/playbooks
openstack-ansible setup-hosts.yml
openstack-ansible haproxy-install.yml
openstack-ansible setup-infrastructure.yml 
```

#### Keystone installation

``` os-keystone-install.yml ```

#### Glance installation

``` os-glance-install.yml ```

#### Cinder installation

``` os-cinder-install.yml ```

#### Nova installation

``` os-nova-install.yml ```

#### Neutron installation

``` os-neutron-install.yml ```

#### Heat installation

``` os-heat-install.yml ```

#### Horizon installation

``` os-horizon-install.yml ```

#### Ceilometer installation

``` os-ceilometer-install.yml ```

#### Aodh installation

``` os-aodh-install.yml ```

#### Swift installation

``` os-swift-install.yml ```
