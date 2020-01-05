#!/bin/bash

MODE=$1

KUBEADM_OPT=""
KUBECTL_OPT=""

if [[ "${MODE}" == "restore" ]]; then 
    KUBEADM_OPT="--ignore-preflight-errors=DirAvailable--var-lib-etcd"
fi

# run kubeadm init with the right arguments
# https://unix.stackexchange.com/questions/415990/how-can-i-expand-a-quoted-variable-to-nothing-if-its-empty
kubeadm init --pod-network-cidr=192.168.0.0/16 ${KUBEADM_OPT:+"${KUBEADM_OPT}"}

# setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# untaint master node

if [[ "${MODE}" != "restore" ]]; then
    # apply calico CRDs
    kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
fi

# remove taint from master nodes
kubectl taint nodes --all node-role.kubernetes.io/master-

# bash completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc 
echo 'source <(etcdctl completion bash)' >> ~/.bashrc
echo 'source <(kubeadm completion bash)' >> ~/.bashrc