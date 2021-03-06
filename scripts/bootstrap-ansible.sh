#!/usr/bin/env bash
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# (c) 2014, Kevin Carter <kevin.carter@rackspace.com>

## Shell Opts ----------------------------------------------------------------
set -e -u -x


## Vars ----------------------------------------------------------------------
export HTTP_PROXY=${HTTP_PROXY:-""}
export HTTPS_PROXY=${HTTPS_PROXY:-""}
export ANSIBLE_GIT_RELEASE=${ANSIBLE_GIT_RELEASE:-"v1.9.3-1"}
export ANSIBLE_GIT_REPO=${ANSIBLE_GIT_REPO:-"https://github.com/ansible/ansible"}
export ANSIBLE_ROLE_FILE=${ANSIBLE_ROLE_FILE:-"ansible-role-requirements.yml"}
export ANSIBLE_WORKING_DIR=${ANSIBLE_WORKING_DIR:-/opt/ansible_${ANSIBLE_GIT_RELEASE}}
export SSH_DIR=${SSH_DIR:-"/root/.ssh"}
export UPDATE_ANSIBLE_REQUIREMENTS=${UPDATE_ANSIBLE_REQUIREMENTS:-"yes"}
export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"}

# Install the base packages
APT=`command -v apt-get` || true
YUM=`command -v yum` || true
if [[ "$APT" != "" ]]; then
    apt-get update && apt-get -y install git python-all python-dev curl autoconf g++ python2.7-dev < /dev/null
elif [[ "$YUM" != "" ]]; then
    yum check-update && yum -y install git python2 curl autoconf gcc-c++ python2-devel
fi

# If the working directory exists remove it
if [ -d "${ANSIBLE_WORKING_DIR}" ];then
    rm -rf "${ANSIBLE_WORKING_DIR}"
fi

# Clone down the base ansible source
git clone "${ANSIBLE_GIT_REPO}" "${ANSIBLE_WORKING_DIR}"
pushd "${ANSIBLE_WORKING_DIR}"
    git checkout "${ANSIBLE_GIT_RELEASE}"
    git submodule update --init --recursive
popd

# Ensure we use the HTTPS/HTTP proxy with pip if it is specified
PIP_OPTS=""
if [ -n "$HTTPS_PROXY" ]; then
  PIP_OPTS="--proxy $HTTPS_PROXY"
elif [ -n "$HTTP_PROXY" ]; then
  PIP_OPTS="--proxy $HTTP_PROXY"
fi

# get pip
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
      exit_fail
    fi
  fi

  # Download and install pip
  curl ${GET_PIP_URL} > /opt/get-pip.py
  python2 /opt/get-pip.py || python /opt/get-pip.py
fi

# Install requirements if there are any
if [ -f "requirements.txt" ];then
  pip2 install $PIP_OPTS -r requirements.txt || pip install $PIP_OPTS -r requirements.txt
fi

# Install ansible
pip2 install $PIP_OPTS "${ANSIBLE_WORKING_DIR}" || pip install $PIP_OPTS "${ANSIBLE_WORKING_DIR}"

# Create openstack ansible wrapper tool
cat > /usr/local/bin/openstack-ansible <<EOF
#!/usr/bin/env bash
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# (c) 2014, Kevin Carter <kevin.carter@rackspace.com>

# OpenStack wrapper tool to ease the use of ansible with multiple variable files.

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

function info() {
    echo -e "\e[0;35m\${@}\e[0m"
}

# Discover the variable files.
VAR1="\$(for i in \$(ls /etc/openstack_deploy/user_*.yml); do echo -ne "-e @\$i "; done)"

# Provide information on the discovered variables.
info "Variable files: \"\${VAR1}\""

# Run the ansible playbook command.
\$(which ansible-playbook) \${VAR1} \$@
EOF

# Ensure wrapper tool is executable
chmod +x /usr/local/bin/openstack-ansible

echo "openstack-ansible script created."
echo "System is bootstrapped and ready for use."
