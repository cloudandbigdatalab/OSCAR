pip install python-neutronclient

Add the api access file from dashboard to cc_openrc

source cc_openrc

neutron net-list

neutron port-create sharednet1

neutron port-create sharednet1

neutron port-create sharednet1

unset OS_TENANT_ID
unset OS_REGION_NAME

lxc-ls



lxc-attach --name aio1_neutron_agents_container-128a859f

neutron net-create --provider:physical_network=flat --provider:network_type=flat --shared --router:external my_os_ext_net

neutron subnet-create my_os_ext_net 10.20.108.0/23 --name my_os_ext_subnet --gateway=10.20.109.254 --allocation-pool start=10.20.108.128,end=10.20.108.128 --allocation-pool start=10.20.108.129,end=10.20.108.129 --allocation-pool start=10.20.108.13,end=10.20.108.13


neutron router-create router1

neutron router-gateway-set router1 my_os_ext_net





