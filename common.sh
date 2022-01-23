#!/bin/bash
set -e


sudo cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.73.100 master.calvarado04.com
192.168.73.200 worker0.calvarado04.com
192.168.73.201 worker1.calvarado04.com
192.168.73.202 worker2.calvarado04.com
EOF


apt-get update

apt-get install -y apt-transport-https ca-certificates curl jq docker.io linux-headers-$(uname -r) gcc cloud-guest-utils xfsprogs

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

apt-get install -y kubelet=${KUBERNETES_VERSION}-00 kubeadm=${KUBERNETES_VERSION}-00 kubectl=${KUBERNETES_VERSION}-00

apt-mark hold kubelet kubeadm kubectl


mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

cat << EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

hostnamectl set-hostname $(hostname).calvarado04.com

systemctl daemon-reload

systemctl restart docker

systemctl enable kubelet

systemctl start kubelet


sysctl --system

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

modprobe br_netfilter
