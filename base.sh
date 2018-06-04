#!/bin/bash
################################################################################
# (c) Copyright 2007-2015 Alces Software Ltd                                   #
#                                                                              #
# Symphony is free software: you can redistribute it and/or modify it under    #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# Symphony is distributed in the hope that it will be useful, but WITHOUT      #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with Symphony.  If not, see <http://www.gnu.org/licenses/>.            #
#                                                                              #
# For more information on the Symphony Toolkit, please visit:                  #
# http://www.alces-software.org/symphony                                       #
#                                                                              #
################################################################################

systemctl stop NetworkManager
systemctl disable NetworkManager

#Install base packages
yum -y install vim vim-common

#Work around for vim dependency
yum -y install gpm-libs

mkdir -p /etc/systemd/system-preset
cat <<EOF > /etc/systemd/system-preset/00-alces-base.preset
disable libvirtd.service
disable NetworkManager.service
disable firewalld.service
EOF

#Disable selinux
sed -e 's/^SELINUX=enforcing.*/SELINUX=disabled/g' -i /etc/selinux/config

#Prep sudo
sed -e "s/Defaults    requiretty/#Defaults    requiretty/g" -i /etc/sudoers

#Setup versions file
cat << EOF > /etc/alces-imageware.yaml
:distro: centos
:distromajorversion: '7'
:buildtime: '`date +'%Y-%m-%d_%H-%M'`'
EOF

#Lock/scramble root password
#dd if=/dev/urandom count=50|md5sum|passwd --stdin root
#passwd -l root

#switch to iptables rather than default firewalld for clusterware native support
yum install -y iptables-services iptables-utils
systemctl enable iptables
cat << EOF > /etc/sysconfig/iptables
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
#SSH
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
#APPLIANCERULES#
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
systemctl stop iptables; systemctl start iptables
