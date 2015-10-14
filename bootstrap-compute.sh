# This script bootstraps a compute node on UTSA's chameleon cloud.
# It takes all the actions necessary for the deployment of the 
# compute node according the the Openstack Ansible Deployment(OSD) 
# architecture (https://github.com/openstack/openstack-ansible).
# Auther(s):
# Miguel Alex Cantu (miguel.cantu@rackspace.com)
# Mohan Muppidi (Mohan.muppidi@utsa.edu)

# IN PROGRESS...

set -e -u -x


# The variables for setting Netmask and Gateway 
export ETH0_NETMASK="255.255.252.0"
export ETH0_GATEWAY="$(ip r | grep default | awk '{print $3}')"

# Input the management ip 
export MANAGEMENT_IP=$1
export VXLAN_IP=$2
export STORAGE_IP=$3


# If br-mgmt bridge is up already, use that for public address and interface.
if grep "br-mgmt" /proc/net/dev > /dev/null;then
  export PUBLIC_INTERFACE="br-mgmt"
  export PUBLIC_ADDRESS=${PUBLIC_ADDRESS:-$(ip -o -4 addr show dev ${PUBLIC_INTERFACE} | awk -F '[ /]+' '/global/ {print $4}' | head -n 1)}
else
  export PUBLIC_ADDRESS=${PUBLIC_ADDRESS:-$(ip -o -4 addr show dev ${PUBLIC_INTERFACE} | awk -F '[ /]+' '/global/ {print $4}')}
fi



#export PUBLIC_INTERFACE=${PUBLIC_INTERFACE:-$(ip -o -4 addr show dev ${PUBLIC_INTERFACE} | awk -F '[ /]+' '/global/ {print $4}'p route show | awk '/default/ { print $NF }')}
#export PUBLIC_ADDRESS=${PUBLIC_ADDRESS:-$(ip -o -4 addr show dev ${PUBLIC_INTERFACE} | awk -F '[ /]+' '/global/ {print $4}')}

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

# We don't need a Key pair for the compute node. Public key from controller node will be injected.

# Ensure that the ssh key exists and is an authorized_key
#key_path="${HOME}/.ssh"
#key_file="${key_path}/id_rsa"

# Ensure that the .ssh directory exists and has the right mode
#if [ ! -d ${key_path} ]; then
#  mkdir -p ${key_path}
#  chmod 700 ${key_path}
#fi

#if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
#  rm -f ${key_file}*
#  ssh-keygen -t rsa -f ${key_file} -N ''
#fi

# Ensure that the public key is included in the authorized_keys
# for the default root directory and the current home directory
#key_content=$(cat "${key_file}.pub")
#if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
#  echo "${key_content}" | tee -a ${key_path}/authorized_keys
#fi

# Copy aio network config into place.
if [ ! -d "/etc/network/interfaces.d" ];then
  mkdir -p /etc/network/interfaces.d/
fi

# Copy the basic aio network interfaces over
cp -R compute-interfaces.cfg.template /etc/network/interfaces.d/compute-interfaces.cfg

# Modify the file to match the IPs given by the user.
sed -i "s/ETH0IP/$PUBLIC_ADDRESS/g" /etc/network/interfaces.d/compute-interfaces.cfg
sed -i "s/MGMTIP/$MANAGEMENT_IP/g" /etc/network/interfaces.d/compute-interfaces.cfg
sed -i "s/ETH0NETMASK/$ETH0_NETMASK/g" /etc/network/interfaces.d/compute-interfaces.cfg
sed -i "s/ETH0GATEWAY/$ETH0_GATEWAY/g" /etc/network/interfaces.d/compute-interfaces.cfg
sed -i "s/VXLAN_IP/$VXLAN_IP/g" /etc/network/interfaces.d/compute-interfaces.cfg
sed -i "s/STORAGE_IP/$STORAGE_IP/g" /etc/network/interfaces.d/compute-interfaces.cfg





cp -R interfaces.template /etc/network/interfaces







echo "------DONE!!------"
