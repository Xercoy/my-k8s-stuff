#!/bin/sh

# run kubeadm init with the right arguments
kubeadm init --pod-network-cidr=192.168.0.0/16

# setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply calico CRDs
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
