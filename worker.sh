#!/bin/bash
set -e


export PX_METADATA_NODE_LABEL="kubernetes.io/role=infra"


kubeadm join master.calvarado04.com:6443 --token ${TOKEN} \
  --discovery-token-unsafe-skip-ca-verification


DROPLET_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

echo $DROPLET_IP_ADDRESS

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$DROPLET_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload

systemctl restart kubelet

