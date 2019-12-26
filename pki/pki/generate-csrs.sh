#!/bin/bash
# note: use sh instead - https://stackoverflow.com/questions/3411048/unexpected-operator-in-shell-programming
# script to generate certs needed for k8s

DESIRED_CERT_TYPE=$1
NODE_NAME=$2

TYPES="admin, kubelet, kube-controller-manager, kube-proxy, kube-scheduler, kube-api-server, service-account (requires node name as arg #2), kube-controller-manager"
CSR_COMMON_NAME=""
CSR_ORGANIZATION_NAME=""
DEFAULT_CSR=""

if [[ "${DESIRED_CERT_TYPE}" == "" ]]; then
    echo "desired cert type required; valid types: ${TYPES}"
    exit
fi

# admin access
if [[ "${DESIRED_CERT_TYPE}" == "admin" ]]; then
    CSR_COMMON_NAME="admin"
    CSR_ORGANIZATION_NAME="system:masters"
fi

# kubelet
if [[ "${DESIRED_CERT_TYPE}" == "kubelet" ]]; then
    CSR_COMMON_NAME="system:node:${NODE_NAME}"
    CSR_ORGANIZATION_NAME="system:nodes"
fi

# kube-controller-manager
if [[ "${DESIRED_CERT_TYPE}"  == "kube-controller-manager" ]]; then
    CSR_COMMON_NAME="system:kube-controller-manager"
    CSR_ORGANIZATION_NAME="system:kube-controller-manager"
fi

# kube-proxy
if [[ "${DESIRED_CERT_TYPE}" == "kube-proxy" ]]; then
    CSR_COMMON_NAME="system:kube-proxy"
    CSR_ORGANIZATION_NAME="system:node-proxier"
fi

# kube-scheduler
if [[ "${DESIRED_CERT_TYPE}" == "kube-scheduler" ]]; then
    CSR_COMMON_NAME="system:kube-scheduler"
    CSR_ORGANIZATION_NAME="system:kube-scheduler"
fi

# kube-api-server
if [[ "${DESIRED_CERT_TYPE}" == "kube-api-server" ]]; then
    CSR_COMMON_NAME="kubernetes"
    CSR_ORGANIZATION_NAME="Kubernetes"
fi

# service account
if [[ "${DESIRED_CERT_TYPE}" == "service-account" ]]; then
    CSR_COMMON_NAME="service-accounts"
    CSR_ORGANIZATION_NAME="Kubernetes"
fi

# multi-line strings
# https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
read -r -d '' CSR <<EOM
{
  "CN": "${CSR_COMMON_NAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "USA",
      "L": "Los Angeles",
      "O": "${CSR_ORGANIZATION_NAME}",
      "OU": "devops",
      "ST": "California"
    }
  ]
} 
EOM

echo "${CSR}"
