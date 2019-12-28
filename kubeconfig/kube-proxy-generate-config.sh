#!/bin/bash
set -x

# this seems to usually be whatever is under the CN space
CREDENTIAL_NAME="system:kube-proxy"
KUBECONFIG_FILE_NAME="kube-proxy.kubeconfig"
CONTEXT_NAME="default"

# DEFAULTS THAT SHOULD BE CHANGED TO BE MORE FLEXIBLE
CLUSTER_NAME="prak-default-cluster"
CLUSTER_ENDPOINT="$(hostname -I | awk -F ' ' '{print $1}')"
CA_CERT_PATH="ca.pem"
CA_CERT_KEY="ca-key.pem"

# set a cluster, which requires:
# --embed-certs=true
# --certificate-authority=<cert path>
# --server=https://<endpoint>:6443
# --kubeconfig=<output path of the kubeconfig>
kubectl config set-cluster "${CLUSTER_NAME}" \
--server=https://"${CLUSTER_ENDPOINT}":6443 \
--embed-certs=true \
--certificate-authority="${CA_CERT_PATH}" \
--kubeconfig="${KUBECONFIG_FILE_NAME}"

# set credentials
# this requires the client's cert which includes the public key within it,
# as well as the private key
kubectl config set-credentials "${CREDENTIAL_NAME}" \
--client-certificate="${CA_CERT_PATH}" \
--client-key="${CA_CERT_KEY}" \
--embed-certs=true \
--kubeconfig="${KUBECONFIG_FILE_NAME}"

# set context
# this ties the user credentials and clusters together
kubectl config set-context "${CONTEXT_NAME}" \
--cluster="${CLUSTER_NAME}" \
--user="${CREDENTIAL_NAME}" \
--kubeconfig="${KUBECONFIG_FILE_NAME}"
# no need to embed certs, this is just trying to bits of info together...

# the kubeconfig is created but the current context needs to be set
kubectl config use-context default --kubeconfig="${KUBECONFIG_FILE_NAME}"