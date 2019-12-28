#!/bin/bash
set -x

# generate kubeconfig for clients to use to auth against kube-api-server
# this needs to be done for the kube-controller-manager, kubelet, kube-proxy,
# kube-scheduler, and the admin user.

# The components need to know the IP that the kube-api-server is at.
# This can be the node directly, a load balancer, etc.

# DEFAULTS THAT SHOULD BE CHANGED TO BE MORE FLEXIBLE
KUBERNETES_COMPONENT="kubelet"
KUBERNETES_CLUSTER_NAME="prak-default-cluster"
CA_CERT="ca.pem"

KUBELET_NAME="${HOSTNAME}"
KUBERNETES_PUBLIC_ADDRESS="$(hostname -I | awk -F ' ' '{print $1}')"
KUBERNETES_COMPONENT_CREDENTIAL_NAME="system:node:${KUBELET_NAME}"

# note the required fields when setting a cluster: 
# - the CA cert 
# - cluster endpoint (--server = https://<endpoint>:6443)
# - cluster name (first argument)
# - option to embed certs in the kubeconfig file (--kubeconfig)
kubectl config set-cluster "${KUBERNETES_CLUSTER_NAME}" \
--certificate-authority="${CA_CERT}" \
--embed-certs=true \
--server=https://"${KUBERNETES_PUBLIC_ADDRESS}":6443 \
--kubeconfig="${KUBERNETES_COMPONENT}.kubeconfig"

# when setting the credentials for a kubelet, the name of the
# credentials for the cert must match the CN/common name
# specified in the cert which was made from the CSR.
kubectl config set-credentials "${KUBERNETES_COMPONENT_CREDENTIAL_NAME}" \
--client-certificate="${KUBERNETES_COMPONENT}.pem" \
--client-key="${KUBERNETES_COMPONENT}-key.pem" \
--embed-certs=true \
--kubeconfig="${KUBERNETES_COMPONENT}.kubeconfig"

kubectl config set-context default \
--cluster="${KUBERNETES_CLUSTER_NAME}" \
--user="system:node:${KUBELET_NAME}" \
--kubeconfig="${KUBERNETES_COMPONENT}.kubeconfig"

kubectl config use-context default --kubeconfig="${KUBERNETES_COMPONENT}.kubeconfig" 