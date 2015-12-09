#!/usr/bin/env python

# Author(s):
# Miguel Alex Cantu (miguel.cantu@rackspace.com)

import json
import os
import yaml

INVENTORY_SKEL = {
    '_meta': {
        'hostvars': {}
    }
}

starting_ip_for_bridges = 100

def main():
	# Read configuration file
	with open("/etc/oscar/oscar.conf", 'r') as f:
		conf_dict = yaml.safe_load(f.read())
	#print conf_dict

	dynamic_inventory = INVENTORY_SKEL

	dynamic_inventory["_meta"]["hostvars"]["controller"] = _build_controller_dict(conf_dict)
	
	# Build compute nodes host vars
	compute_num = 1
	for compute_ip in conf_dict["nodes"]["computes"]:
		compute_name = "compute" + str(compute_num)
		dynamic_inventory["_meta"]["hostvars"][compute_name] = _build_compute_dict(compute_ip, conf_dict['network'])
		compute_num += 1

	cinder_num = 1
	try:
		for cinder_ip in conf_dict["nodes"]["cinder"]["ips"]:
			cinder_name = "cinder" + str(cinder_num)
			dynamic_inventory["_meta"]["hostvars"][cinder_name] = _build_cinder_hostvar_dict(
				cinder_ip,
				conf_dict['network'],
				conf_dict['nodes']['cinder']['backend_configurations'])
			cinder_num += 1
	except KeyError:
		print "No cinder configurations found in /etc/oscar/oscar.conf. Using the controller for cinder block-storage"
	
	# Add mgmt_ip for each compute to the controller dict
	# and build out host groups
	dynamic_inventory['compute_nodes'] = { 'hosts': [] }
	dynamic_inventory['cinder_nodes'] = { 'hosts': [] }
	for host_name, variables in dynamic_inventory["_meta"]["hostvars"].iteritems():
		if 'compute' in host_name:
			dynamic_inventory['_meta']['hostvars']['controller'][host_name + '_mgmt_ip'] = variables['compute_mgmt_ip'] 
			dynamic_inventory['compute_nodes']['hosts'].append(host_name)
		elif 'cinder' in host_name:
			dynamic_inventory["cinder_nodes"]["hosts"].append(host_name)
		elif 'controller' in host_name:
			dynamic_inventory[host_name] = { "hosts": ["controller"] }

	print json.dumps(dynamic_inventory, indent=4, sort_keys=True)

def _build_compute_dict(compute_ip, network_dict):
	"""
	This methods builds a dictionary out of the compute host's IP
	list for the sake of assigning them a host name
	"""
	global starting_ip_for_bridges
	compute_dict = {}
	compute_dict["ansible_ssh_host"] = compute_ip

	ip_allocations = _assign_ip_to_bridges_from_network(network_dict)

	compute_dict["compute_mgmt_ip"] = ip_allocations['mgmt_ip']
	compute_dict['compute_vxlan_ip'] = ip_allocations['vxlan_ip']
	compute_dict['compute_storage_ip'] = ip_allocations['storage_ip']
    
    # Incrementing IP for next host
	starting_ip_for_bridges += 1

	return compute_dict

def _build_cinder_hostvar_dict(cinder_ip, network_dict, backend_config_dict):
	"""
	This method builds the hostvar dictionary for cinder host 'cinder_ip'.
	"""
	global starting_ip_for_bridges
	cinder_hostvar_dict = {}
	cinder_hostvar_dict['ansible_ssh_host'] = cinder_ip

	ip_allocations = _assign_ip_to_bridges_from_network(network_dict)

	cinder_hostvar_dict["cinder_mgmt_ip"] = ip_allocations['mgmt_ip']
	cinder_hostvar_dict["cinder_vxlan_ip"] = ip_allocations['vxlan_ip']
	cinder_hostvar_dict["cinder_storage_ip"] = ip_allocations['storage_ip']
	cinder_hostvar_dict["backend_config"] = backend_config_dict

	return cinder_hostvar_dict
	


def _build_controller_dict(conf_dict):
	"""
	This method build the inventory hostvars for the controller node,
	which include the configs defined in the "network" block
	"""
	global starting_ip_for_bridges
	controller_dict = conf_dict['network']	
	controller_dict["ansible_ssh_host"] = conf_dict["nodes"]["controller"]
	ip_allocations = _assign_ip_to_bridges_from_network(conf_dict['network'])
	controller_dict['controller_mgmt_ip'] = ip_allocations['mgmt_ip']
	starting_ip_for_bridges += 1

	return controller_dict


def _assign_ip_to_bridges_from_network(network_dict):
	network_string = network_dict
	allocations = {}
	for network_type, network in network_dict.iteritems():
		# ignore gateway
		if network_type == 'vm_gateway':
			continue
		network_octet_list = network.split('.')
		network_octet_list[-1] = str(starting_ip_for_bridges)
		if network_type == 'container_network':
			allocations['mgmt_ip'] = ".".join(network_octet_list)
		elif network_type == 'tunnel_network':
			allocations['vxlan_ip'] = ".".join(network_octet_list)
		elif network_type == 'storage_network':
			allocations['storage_ip'] = ".".join(network_octet_list)

	return allocations
		
if __name__ == '__main__':
    main()
