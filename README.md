# px-virtualbox

A Kubernetes cluster installed with Kubeadm aligned to CKA, CKAD and CKS specifications with Portworx, deployed using Vagrant on Virtualbox.

# Prerequisites

Install Vagrant and Virtualbox on Linux or macOS hosts\
\
-64GB of RAM recommended.\
-12CPUs recommended.\
-600GB of free storage Flash storage recommended, I have 1TB on my laptop.

You can customize the resources of your master node and your worker nodes by separate modifying the Vagrantfile.\
Your worker nodes will have the same resources that you specify for the worker nodes group.

# Now using Ubuntu 20.04 instead of CentOS

This version has been updated to Ubuntu 20.04 due to CentOS has been deprecated, creating only one disk of 200GB per worker node, one kvdb disk of 50GB and the root partition uses 40GB.

# Using Calico instead of Flannel

Due to the CKA, CKAD and CKS certifications uses Calico, I upgraded this cluster to use it instead of Flannel.

Current versions (this can change in the future), that are working:\
\
-Kubernetes 1.23.5.
\
-Kernel 5.4.0-96 with kernel-headers installed.
\
-Portworx 2.9.1.3 with CSI enabled.
\
-Stork 2.8.2.
\
-NGINX Ingress Controller v.1.1.1

# Deploy Portworx Essentials instead of Portworx Enterprise

Portworx Essentials is for free, up to 5 nodes and with some other limitations.

You can deploy Portworx Essentials instead of Portworx Enterprise which will have to be activated after 30 days.

Before to create the cluster, modify the main script CreateCluster.sh, comment the line that installs PX Enterprise and uncomment the line that installs Essentials.
 
# Create the cluster

```
$ ./CreateCluster.sh
$ vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes"
NAME      STATUS   ROLES                  AGE     VERSION
master.calvarado04.com    Ready    control-plane,master   8m29s   v1.23.5
worker0.calvarado04.com   Ready    <none>                 6m10s   v1.23.5
worker1.calvarado04.com   Ready    <none>                 3m27s   v1.23.5
worker2.calvarado04.com   Ready    <none>                 65s     v1.23.5

```

# Check the Portworx Cluster

```
$ vagrant ssh master -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config
$ kubectl get nodes
NAME                  STATUS   ROLES                  AGE     VERSION
master.calvarado04.com    Ready    control-plane,master   15m     v1.23.5
worker0.calvarado04.com   Ready    <none>                 13m     v1.23.5
worker1.calvarado04.com   Ready    <none>                 11m     v1.23.5
worker2.calvarado04.com   Ready    <none>                 8m58s   v1.23.5
```
Check the PX pods status:

```
$ POD=$(kubectl get pods -o wide -n kube-system -l name=portworx | tail -1 | awk '{print $1}')
$ kubectl logs ${POD} -n kube-system -f
[ ctrl+c ]
$ kubectl exec -it pod/${POD} -n kube-system -- /opt/pwx/bin/pxctl status
```
![pxctl status](/images/px-status.png)

You can use Lens too.

![pxctl status](/images/cluster.png)


# Monitoring enabled

Follow this guide to enable Grafana:\
\
https://docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1
\
\
Cluster dashboard\
![Cluster dashboard](/images/grafana-cluster.png)\
\
Node dashboard\
![Node dashboard](/images/grafana-node.png)\
\
ETCD dashboard\
![ETCD dashboard](/images/grafana-etcd.png)\
\
Volume dashboard\
![Volume dashboard](/images/grafana-volume.png)

# About this project

This is a derivative project from:

https://github.com/dotnwat/k8s-vagrant-libvirt 

Includes a Portworx deployment on a 3 worker node cluster and 1 master node.\

It creates 3 virtual disks per worker node. Uses 12GB of RAM per node, I would recommend to have at least 64GB of RAM on your host.

Portworx pods will take up to 10 minutes to become ready.
