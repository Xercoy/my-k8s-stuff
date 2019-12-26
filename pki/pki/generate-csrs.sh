#!/bin/bash
# note: use sh instead - https://stackoverflow.com/questions/3411048/unexpected-operator-in-shell-programming
# script to generate certs needed for k8s

DESIRED_CERT_TYPE=$1
NODE_NAME=$2

TYPES="admin, kubelet, kube-controller-manager, kube-proxy, kube-scheduler, kube-api-server, service-account (requires node name as arg #2), kube-controller-manager"
CSR_COMMON_NAME=""
CSR_ORGANIZATION_NAME=""
DEFAULT_CSR=""

generate_csrs() {
# multi-line strings
# https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
# TODO: make it possible to obtain the config from a file
  CSR_FILE_NAME=$1

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
  echo "${CSR}" >> "${CSR_FILE_NAME}-csr.json"
}



if [[ "${DESIRED_CERT_TYPE}" == "" ]]; then
    echo "desired cert type required; use 'all' to generate all of them. valid types: ${TYPES}"
    exit
fi

# admin access
if [[ "${DESIRED_CERT_TYPE}" == "admin" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="admin"
    CSR_ORGANIZATION_NAME="system:masters"
    CSR_FILE_NAME="admin-csr.json"

    # generate CSR
    generate_csrs admin
fi

# kubelet
if [[ "${DESIRED_CERT_TYPE}" == "kubelet" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="system:node:${HOSTNAME}"
    CSR_ORGANIZATION_NAME="system:nodes"
    generate_csrs kubelet
fi

# kube-controller-manager
if [[ "${DESIRED_CERT_TYPE}"  == "kube-controller-manager" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="system:kube-controller-manager"
    CSR_ORGANIZATION_NAME="system:kube-controller-manager"
    generate_csrs kube-controller-manager
fi

# kube-proxy
if [[ "${DESIRED_CERT_TYPE}" == "kube-proxy" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="system:kube-proxy"
    CSR_ORGANIZATION_NAME="system:node-proxier"
    generate_csrs kube-proxy
fi

# kube-scheduler
if [[ "${DESIRED_CERT_TYPE}" == "kube-scheduler" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="system:kube-scheduler"
    CSR_ORGANIZATION_NAME="system:kube-scheduler"
    generate_csrs kube-scheduler
fi

# kube-api-server
if [[ "${DESIRED_CERT_TYPE}" == "kube-api-server" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="kubernetes"
    CSR_ORGANIZATION_NAME="Kubernetes"
    generate_csrs kube-api-server
fi

# service account
if [[ "${DESIRED_CERT_TYPE}" == "service-account" || "${DESIRED_CERT_TYPE}" == "all" ]]; then
    CSR_COMMON_NAME="service-accounts"
    CSR_ORGANIZATION_NAME="Kubernetes"
    generate_csrs service-account
fi

echo "CSR generation complete"