# This script bootstraps a controller node on UTSA's chameleon cloud.
# It takes all the actions necessary for the deployment of the 
# controller according the the Openstack Ansible Deployment(OSD) 
# architecture (https://github.com/openstack/openstack-ansible).
# This script does not deploy a highly available controller node.
# The container affinity is set to 1 for the database, messaging
# queue, and API services.
# Auther(s):
# Miguel Alex Cantu (miguel.cantu@rackspace.com)

set -e -u -x


export ADMIN_PASSWORD=${ADMIN_PASSWORD:-$DEFAULT_PASSWORD}
export PUBLIC_INTERFACE=${PUBLIC_INTERFACE:-$(ip route show | awk '/default/ { print $NF }')}
export PUBLIC_ADDRESS=${PUBLIC_ADDRESS:-$(ip -o -4 addr show dev ${PUBLIC_INTERFACE} | awk -F '[ /]+' '/global/ {print $4}')}

UBUNTU_RELEASE=$(lsb_release -sc)
UBUNTU_REPO=${UBUNTU_REPO:-$(awk "/^deb .*ubuntu\/? ${UBUNTU_RELEASE} main/ {print \$2; exit}" /etc/apt/sources.list)}
UBUNTU_SEC_REPO=${UBUNTU_SEC_REPO:-$(awk "/^deb .*ubuntu\/? ${UBUNTU_RELEASE}-security main/ {print \$2; exit}" /etc/apt/sources.list)}

# Ensure that the current kernel can support vxlan
if ! modprobe vxlan; then
  echo "VXLAN support is required for this to work. And the Kernel module was not found."
  echo "This build will not work without it."
  exit
fi

# Set base DNS to google, ensuring consistent DNS in different environments
if [ ! "$(grep -e '^nameserver 8.8.8.8' -e '^nameserver 8.8.4.4' /etc/resolv.conf)" ];then
  echo -e '\n# Adding google name servers\nnameserver 8.8.8.8\nnameserver 8.8.4.4' | tee -a /etc/resolv.conf
fi

# Ensure that the https apt transport is available before doing anything else
apt-get update && apt-get install -y apt-transport-https < /dev/null


# Set the host repositories to only use the same ones, always, for the sake of consistency.
cat > /etc/apt/sources.list <<EOF
# Base repositories
deb ${UBUNTU_REPO} ${UBUNTU_RELEASE} main restricted universe multiverse
# Updates repositories
deb ${UBUNTU_REPO} ${UBUNTU_RELEASE}-updates main restricted universe multiverse
# Backports repositories
deb ${UBUNTU_REPO} ${UBUNTU_RELEASE}-backports main restricted universe multiverse
# Security repositories
deb ${UBUNTU_SEC_REPO} ${UBUNTU_RELEASE}-security main restricted universe multiverse
EOF

# Update the package cache
apt-get update

# Install required packages
apt-get install -y bridge-utils \
                   build-essential \
                   curl \
                   ethtool \
                   git-core \
                   ipython \
                   linux-image-extra-$(uname -r) \
                   lvm2 \
                   python2.7 \
                   python-dev \
                   tmux \
                   vim \
                   vlan \
                   xfsprogs < /dev/null

# Flush all the iptables rules.
# Flush all the iptables rules.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Ensure that sshd permits root login, or ansible won't be able to connect
if grep "^PermitRootLogin" /etc/ssh/sshd_config > /dev/null; then
  sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
fi

# Create /opt if it doesn't already exist
if [ ! -d "/opt" ];then
  mkdir /opt
fi

# Remove the pip directory if its found
if [ -d "${HOME}/.pip" ];then
  rm -rf "${HOME}/.pip"
fi

# Install pip
# if pip is already installed, don't bother doing anything
if [ ! "$(which pip)" ]; then

  # if GET_PIP_URL is set, then just use it
  if [ -z "${GET_PIP_URL:-}" ]; then

    # Find and use an available get-pip download location.
    if curl --silent https://bootstrap.pypa.io/get-pip.py; then
      export GET_PIP_URL='https://bootstrap.pypa.io/get-pip.py'
    elif curl --silent https://raw.github.com/pypa/pip/master/contrib/get-pip.py; then
      export GET_PIP_URL='https://raw.github.com/pypa/pip/master/contrib/get-pip.py'
    else
      echo "A suitable download location for get-pip.py could not be found."
      exit
    fi
  fi

  # Download and install pip
  curl ${GET_PIP_URL} > /opt/get-pip.py
  python2 /opt/get-pip.py || python /opt/get-pip.py
fi

# Make the system key used for bootstrapping self
if [ ! -d /root/.ssh ];then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
fi

# Ensure that the ssh key exists and is an authorized_key
key_path="${HOME}/.ssh"
key_file="${key_path}/id_rsa"

# Ensure that the .ssh directory exists and has the right mode
if [ ! -d ${key_path} ]; then
  mkdir -p ${key_path}
  chmod 700 ${key_path}
fi
if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
  rm -f ${key_file}*
  ssh-keygen -t rsa -f ${key_file} -N ''
fi

# Ensure that the public key is included in the authorized_keys
# for the default root directory and the current home directory
key_content=$(cat "${key_file}.pub")
if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
  echo "${key_content}" | tee -a ${key_path}/authorized_keys
fi

# Copy aio network config into place.
if [ ! -d "/etc/network/interfaces.d" ];then
  mkdir -p /etc/network/interfaces.d/
fi

# Copy the basic aio network interfaces over
cp -R controller-interfaces.cfg /etc/network/interfaces.d/

# ------------ Come back to this -------------
## NOTE: We have to ensure network source is in place for network
## configs to take place.
# Bring up the new interfaces
#for i in $(awk '/^iface/ {print $2}' /etc/network/interfaces.d/aio_interfaces.cfg); do
#    if grep "^$i\:" /proc/net/dev > /dev/null;then
#      /sbin/ifdown $i || true
#    fi
#    /sbin/ifup $i || true
#done

# Instead of moving the AIO files in place, it will move our custom
# configs in place.
#cp -R etc/openstack_deploy /etc/
#for i in $(find /etc/openstack_deploy/ -type f -name '*.aio');do
#  rename 's/\.aio$//g' $i
#done

# Ensure the conf.d directory exists
#if [ ! -d "/etc/openstack_deploy/conf.d" ];then
#  mkdir -p "/etc/openstack_deploy/conf.d"
#fi

# Generate the passwords
# scripts/pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

#change the generated passwords for the OpenStack (admin)
#sed -i "s/keystone_auth_admin_password:.*/keystone_auth_admin_password: ${ADMIN_PASSWORD}/" /etc/openstack_deploy/user_secrets.yml
#sed -i "s/external_lb_vip_address:.*/external_lb_vip_address: ${PUBLIC_ADDRESS}/" /etc/openstack_deploy/openstack_user_config.yml

# Change affinities (number of containers per host) if the appropriate
# environment variables are set.
#for container_type in keystone galera rabbit_mq horizon repo; do
#  var_name="NUM_${container_type}_CONTAINER"
#  set +u
#  num=${!var_name}
#  set -u
#  [[ -z $num ]] && continue
#  sed -i "s/${container_type}_container:.*/${container_type}_container: ${num}/" /etc/openstack_deploy/openstack_user_config.yml
#done

#if [ ${DEPLOY_CEILOMETER} == "yes" ]; then
#  # Install mongodb on the aio1 host
#  apt-get install mongodb-server mongodb-clients python-pymongo -y < /dev/null
#  # Change bind_ip to management ip
#  sed -i "s/^bind_ip.*/bind_ip = $MONGO_HOST/" /etc/mongodb.conf
#  # Asserting smallfiles key
#  sed -i "s/^smallfiles.*/smallfiles = true/" /etc/mongodb.conf
#  service mongodb restart
#
#  # Wait for mongodb to restart
#  for i in {1..12}; do
#    mongo --host $MONGO_HOST --eval ' ' && break
#    sleep 5
#  done
#  #Adding the ceilometer database
#  mongo --host $MONGO_HOST --eval '
#    db = db.getSiblingDB("ceilometer");
#    db.addUser({user: "ceilometer",
#    pwd: "ceilometer",
#    roles: [ "readWrite", "dbAdmin" ]})'
#
#  # change the generated passwords for mongodb access
#  sed -i "s/ceilometer_container_db_password:.*/ceilometer_container_db_password: ceilometer/" /etc/openstack_deploy/user_secrets.yml
#  # Change the Ceilometer user variables necessary for deployment
#  sed -i "s/ceilometer_db_ip:.*/ceilometer_db_ip: ${MONGO_HOST}/" /etc/openstack_deploy/user_variables.yml
#  # Enable Ceilometer for Swift
#  if [ ${DEPLOY_SWIFT} == "yes" ]; then
#    sed -i "s/swift_ceilometer_enabled:.*/swift_ceilometer_enabled: True/" /etc/openstack_deploy/user_variables.yml
#  fi
#  # Enable Ceilometer for other OpenStack Services
#  if [ ${DEPLOY_OPENSTACK} == "yes" ]; then
#    for svc in cinder glance heat nova; do
#      sed -i "s/${svc}_ceilometer_enabled:.*/${svc}_ceilometer_enabled: True/" /etc/openstack_deploy/user_variables.yml
#    done
#  fi
#  echo 'tempest_service_available_ceilometer: true' | tee -a /etc/openstack_deploy/user_variables.yml
#fi

## Service region set
#echo "service_region: ${SERVICE_REGION}" | tee -a /etc/openstack_deploy/user_variables.yml
#
## Virt type set
#echo "nova_virt_type: ${NOVA_VIRT_TYPE}" | tee -a /etc/openstack_deploy/user_variables.yml
#
## Set network for tempest
#echo "tempest_public_subnet_cidr: ${TEMPEST_FLAT_CIDR}" | tee -a /etc/openstack_deploy/user_variables.yml
#
## Minimize galera cache
#echo 'galera_innodb_buffer_pool_size: 512M' | tee -a /etc/openstack_deploy/user_variables.yml
#echo 'galera_innodb_log_buffer_size: 32M' | tee -a /etc/openstack_deploy/user_variables.yml
#echo 'galera_wsrep_provider_options:
# - { option: "gcache.size", value: "32M" }' | tee -a /etc/openstack_deploy/user_variables.yml
#
## Set the running kernel as the required kernel
#echo "required_kernel: $(uname --kernel-release)" | tee -a /etc/openstack_deploy/user_variables.yml
#
## Set the Ubuntu apt repository used for containers to the same as the host
#echo "lxc_container_template_main_apt_repo: ${UBUNTU_REPO}" | tee -a /etc/openstack_deploy/user_variables.yml
#echo "lxc_container_template_security_apt_repo: ${UBUNTU_SEC_REPO}" | tee -a /etc/openstack_deploy/user_variables.yml
#
## Set the running neutron workers to 0/1
#echo "neutron_api_workers: 0" | tee -a /etc/openstack_deploy/user_variables.yml
#echo "neutron_rpc_workers: 0" | tee -a /etc/openstack_deploy/user_variables.yml
#echo "neutron_metadata_workers: 1" | tee -a /etc/openstack_deploy/user_variables.yml

echo "------DONE!!------"
