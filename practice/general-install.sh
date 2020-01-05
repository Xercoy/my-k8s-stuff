#!/bin/bash
# this sets up a master node for each 
{
# clone repo and change dirs to it
git clone https://github.com/xercoy/my-k8s-stuff
cd my-k8s-stuff/

# install defaults and docker
./general/setup.sh
./general/install-docker.sh

# install kubelet, kubeadm, and kubectl on the system
./kubeadm/ubuntu-master-node-setup.sh

# start cluster with kubeadm init, install calico, setup kubeconfig, etc
kubeadm/kubeadm-init.sh

# install etcd, etcdctl
./etcd/install-etcd-stuff.sh
}