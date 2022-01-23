#!/bin/bash
set -e

kubeadm config images pull

kubeadm init --pod-network-cidr=10.244.0.0/16 \
        --token ${TOKEN} --apiserver-advertise-address=${MASTER_IP} --kubernetes-version=v1.22.5

DROPLET_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

echo $DROPLET_IP_ADDRESS

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$DROPLET_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload

systemctl restart kubelet

KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /tmp/calico.yml

#sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf taint node master.calvarado04.com node-role.kubernetes.io/master:NoSchedule-
