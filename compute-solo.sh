#!/bin/bash
################################################################################
# (c) Copyright 2016 Alces Software Ltd
#
# Symphony is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# Symphony is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Symphony.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Symphony Toolkit, please visit:
# http://www.alces-software.org/symphony
#
################################################################################
mkdir -p /root/provisioners
cd /root/provisioners
wget https://raw.githubusercontent.com/andrewyuau/alces-flight-ibm-cloud/master/base.sh
/bin/bash /root/provisioners/base.sh

# Override /etc/hosts with a plain, hostname-less version (clusterware
# or other services will manage this.)
cat << 'EOF' > /etc/hosts
# The following lines are desirable for IPv4 capable hosts
127.0.0.1 localhost.localdomain localhost
127.0.0.1 localhost4.localdomain4 localhost4

# The following lines are desirable for IPv6 capable hosts
::1 localhost.localdomain localhost
::1 localhost6.localdomain6 localhost6
EOF

yum -y groupinstall "Development Tools"
yum -y install nano screen emacs
#export cw_DIST=el7
#export cw_BUILD_source_branch=1.6.1
#export cw_BUILD_naming_auth="GNjdioBB+c6r2Dkackqt"
#export cw_BUILD_recorder_url="https://www.google-analytics.com/collect"

#export cw_BUILD_recorder_generator=/tmp/softlayer-generator
#curl -sL https://s3-eu-west-1.amazonaws.com/alces-flight-softlayer/provisioning/softlayer-generator > /tmp/softlayer-generator
# curl -sL http://git.io/clusterware-installer | /bin/bash
curl -sL http://git.io/clusterware-installer | sudo cw_DIST=el7 /bin/bash
source /etc/profile.d/alces-clusterware.sh
#rm -f /tmp/softlayer-generator

#cat <<EOF > /opt/clusterware/etc/defaults.yml
#---
#cluster:
#  scheduler:
#    allocation: autodetect
#EOF
#sed -i -e 's/cw_GRIDWARE_prefer_binary=false/cw_GRIDWARE_prefer_binary=true/g'     /opt/clusterware/etc/gridware.rc
PATH=/opt/clusterware/bin:$PATH
alces handler enable clusterable
alces handler enable cluster-nfs
alces handler enable cluster-gridware
alces handler enable cluster-customizer
alces handler enable cluster-www
alces handler enable cluster-vpn
alces handler enable cluster-appliances
alces handler enable session-firewall
alces handler enable cluster-firewall
alces handler enable taskable
#alces session enable gnome
mkdir -p /opt/apps/etc/modules
alces module use /opt/apps/etc/modules
# Create /opt/apps for user applications
mkdir -p /opt/clusterware/etc/gridware/global
touch /opt/clusterware/etc/gridware/global/modulespath
cat <<EOF >> /opt/clusterware/etc/gridware/global/modulespath
#=User applications
/opt/apps/etc/modules
EOF
cp /opt/clusterware/etc/gridware/depotskel/modules/null /opt/apps/etc/modules
chgrp -R gridware /opt/apps
chmod -R g+rw /opt/apps
#find /opt/apps -type d -exec chmod g+s {} \;
#cat <<\EOF > /opt/clusterware/etc/cluster-nfs.d/cluster-apps.rc
#if [ -d "/opt/apps" ]; then
#  cw_CLUSTER_NFS_exports="${cw_CLUSTER_NFS_exports} /opt/apps"
#fi
#EOF
alces handler enable cluster-sge

export uuid="aeb911ed-3b97-431a-b0d3-ddb642f92c22"
export token="LTekqysJmEoN7kLJ4m40"

    cat <<EOF > /opt/clusterware/etc/config.yml
---
cluster:
  uuid: ${cw_SOFTLAYER_uuid:-$(uuid)}
  token: ${cw_SOFTLAYER_token:-$(uuid)}
  name: ${cw_SOFTLAYER_cluster_name:-cluster}
EOF
    if [ "${cw_SOFTLAYER_machine_role}" == "master" ]; then
        cat <<EOF >> /opt/clusterware/etc/config.yml
  role: ${cw_SOFTLAYER_machine_role:-master}
  tags:
     scheduler_roles: ":master:"
     storage_roles: ":master:"
     access_roles: ":master:"
EOF
    else
        cat <<EOF >> /opt/clusterware/etc/config.yml
  role: slave
  master: '10.63.18.10'
  tags:
     scheduler_roles: ":compute:"
EOF
    fi
    chmod 0640 /opt/clusterware/etc/config.yml
    systemctl start clusterware-configurator
fi

# Setup user account
#useradd -u 1000 alces -G wheel,adm,systemd-journal,gridware
#su - alces -c uptime
#cat /root/.ssh/authorized_keys >> /home/alces/.ssh/authorized_keys
#echo "alces  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
