#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull 

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=192.168.56.100 --pod-network-cidr=190.168.0.0/16 

echo "[TASK 3] Deploy Calico network"


wget  https://docs.projectcalico.org/v3.18/manifests/calico.yaml
#kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml

kubectl create -f calico.yaml

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh



#kubeadm join 192.168.56.100:6443 --token pii6cx.tdcxens3izdn52gy --discovery-token-ca-cert-hash sha256:82b9d3331b6fd21d8e6350603c1c91df079046047249f946a4168f0e0083bf80