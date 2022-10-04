#!/bin/bash

## !IMPORTANT ##
#
## This script is tested only in the generic/ubuntu2004 Vagrant box
## If you use a different version of Ubuntu or a different Ubuntu Vagrant box test this again
#

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw 


#sudo unlink /etc/resolv.conf

#cat >>/etc/resolv.conf<<EOF
#nameserver 10.10.0.1
#EOF

echo "[TASK 3] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system 

echo "[TASK 5] Install containerd runtime"
apt update 
apt install  -y containerd apt-transport-https 
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd 

echo "[TASK 6] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" 

echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00 

echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 10] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.56.100   kmaster.example.com     kmaster
192.168.56.101   kworker1.example.com    kworker1
192.168.56.102   kworker2.example.com    kworker2
192.168.56.103   kworker3.example.com    kworker3
EOF
