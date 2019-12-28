#!/bin/sh
set -ex

# I did this second to last and realized that the client certs are
# different from the ca certs. So obvious; need to take a break...

CLUSTER_NAME="prak-default-cluster"
CA_CERT_PATH="ca.pem"
CA_KEY_PATH="ca-key.pem"
CLUSTER_ENDPOINT="$(hostname -I | awk -F ' ' '{print $1}')"
KUBECONFIG_FILE_PATH="kube-scheduler.kubeconfig"
CREDENTIAL_NAME="system:kube-scheduler"
CONTEXT_NAME="default"
COMPONENT_NAME="kube-scheduler"

# set cluster
kubectl config set-cluster "${CLUSTER_NAME}" \
--certificate-authority="${CA_CERT_PATH}" \
--server=https://127.0.0.1:6443 \
--embed-certs=true \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# set credential
kubectl config set-credential "${CREDENTIAL_NAME}" \
--client-certificate="${COMPONENT_NAME}.pem" \
--client-key="${COMPONENT_NAME}-key.pem" \
--embed-certs=true \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# set context
kubectl config set-context "${CONTEXT_NAME}" \
--cluster="${CLUSTER_NAME}" \
--user="${CREDENTIAL_NAME}" \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# use context
kubectl config use-context "${CONTEXT_NAME}" --kubeconfig="${KUBECONFIG_FILE_PATH}"