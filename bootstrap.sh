#!/bin/bash

###This is the boot strap script for minikube Poc #################
###Aurthor A.K Singh 01092018 ##############################


##Create directory to sync up files from localsystem inside vagrant machine ####
mkdir -p /home/vagrant/files

####Remove old Repository from imgae ##############################
rm -rf /etc/yum.repos.d/centos.repo /etc/yum.repos.d/docker.repo & yum clean all
yum erase -y docker-engine-selinux docker-engine-17.05.0.ce-1.el7.centos.x86_64

####Addd the working repo ##########################################
cat >/etc/yum.repos.d/centos.repo <<EOL
[centos7]
name=Centos7 Repository
baseurl=http://mirror.centos.org/centos/7/os/x86_64/
gpgcheck=0
enabled=1
EOL
######################################################################

###########Installing Pre-Required Packages #########
yum -y install qemu-kvm libvirt libvirt-daemon-kvm jq
yum install -y http://vault.centos.org/centos/7.3.1611/extras/x86_64/Packages/container-selinux-2.10-2.el7.noarch.rpm
yum install -y yum-utils device-mapper-persistent-data lvm2 epel-release wget
yum groupinstall -y "Development Tools"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum install -y docker-ce-18.06.1.ce-3.el7.x86_64
#################################################################################

##Starting Libvirtd & Docker Servies#############################################
systemctl start libvirtd
systemctl enable libvirtd
systemctl start docker
systemctl enable docker
#########################################################################
############	Configure Kubernetes repository and Install Minikube. #####

cat <<'EOF' > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

############################################################################

#####Installing Kubectl ####################################################
yum -y install kubectl
##############################################################################

################Download MiniKube and Docker Mchine_Kvm #######################
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O minikube
wget https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2

chmod 755 minikube docker-machine-driver-kvm2
mv minikube docker-machine-driver-kvm2 /usr/local/bin/

ln -s /usr/local/bin/minikube /usr/bin/minikube
ln -s /usr/local/bin/docker-machine-driver-kvm2 /usr/bin/docker-machine-driver-kvm2


#################################################################################

######################Starting Minikube Services #################################
minikube start --vm-driver=none
minikube service list
##################################################################################
