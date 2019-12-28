#!/bin/sh
set -ex

# doing this by memory. didn't do too bad
CLUSTER_NAME="prak-default-cluster"
CA_CERT_PATH="ca.pem"
CA_KEY_PATH="ca-key.pem"
CLUSTER_ENDPOINT="$(hostname -I | awk -F ' ' '{print $1}')"
KUBECONFIG_FILE_PATH="kube-controller-manager.kubeconfig"
CREDENTIAL_NAME="system:kube-controller-manager"
CONTEXT_NAME="default"
COMPONENT_NAME="kube-scheduler"

# flag: certificate authority, embed certs, kubeconfig, server
# I forgot server....
# anything within the master node reports back to localhost
kubectl config set-cluster "${CLUSTER_NAME}" \
--certificate-authority="${CA_CERT_PATH}" \
--embed-certs=true \
--server=https://"127.0.0.1:6443" \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# credential name is also explicitly known as common name in CSRs (CN field)
# it's client-certificate, not certificate-authority...
# it's client-key, not certificate key... wth
kubectl config set-credentials "${CREDENTIAL_NAME}" \
--client-certificate="${COMPONENT_NAME}.pem" \
--client-key="${COMPONENT_NAME}-key.pem" \
--embed-certs=true \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# I forgot user...
kubectl config set-context "${CONTEXT_NAME}" \
--cluster="${CLUSTER_NAME}" \
--user="${CREDENTIAL_NAME}" \
--kubeconfig="${KUBECONFIG_FILE_PATH}"

# set the context created as the active one in the kubeconfig
kubectl config use-context "${CONTEXT_NAME}" --kubeconfig="${KUBECONFIG_FILE_PATH}"