#!/bin/bash

set -x
# autogenerate TLS certs

# todp:
# flexibility - assumptions of files are hardcoded
# default checks for configuration files, etc

CSR_DEFAULT_COMPONENTS=("admin" "kublet" "kube-controller-manager" "kube-proxy" "kube-scheduler" "kube-api-server" "service-account")
CA_CONFIG_PROFILE="kubernetes"

COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT=""

# this is the certificate
# this script issues certs and acts as the CA
# based on the CSRs received.
# hardcoded, ugly, but not the point now
CA_CERT="ca.pem"
CA_KEY="ca-key.pem"

# generate default config for now
CA_CONFIG_FILEPATH="./default-ca-config.json"

read -r -d '' CA_CONFIG_FILE <<EOM
{
    "signing": {
        "defaults": {
            "expiry": "8760h"
        },
        "profiles": {
            "Kubernetes": {
                "expiry": "8760h",
                "usages": ["signing", "key encipherment", "client auth", "server auth"]
            }
        }
    }
}
EOM

echo "${CA_CONFIG_FILE}" > "${CA_CONFIG_FILEPATH}"

function gencert() {
    cfssl gencert \
    -ca="${CA_CERT}" \
    -ca-key="${CA_KEY}" \
    -config="${CA_CONFIG_FILEPATH}" \
    -profile="${CA_CONFIG_PROFILE} ${COMPONENT_CUSTOM_COMMAND}" \
    "${CSR_COMPONENT}-csr.json" | cfssljson -bare "${CSR_COMPONENT}"
}

# issue the admin CSR
# no custom commands
# being redundant for rendundancy's sake
COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT="admin"
gencert

# issue cert and private key for kubelet
# note the extra flag for the hostname, this represents all of the sources
# in which requests for the kubelet might come from.
# "CN": "system:node:${HOSTNAME}"
# "O": "system:nodes"
COMPONENT_CUSTOM_COMMAND="-hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP}"
CSR_COMPONENT="kubelet"
gencert

# kube-controller-manager
# remember that the key field values in the CSR
# "CN": "system:kube-scheduler"
# "O": "system:kube-scheduler"
COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT="kubele-controller-manager"
gencert

# kube-proxy TLS certs
# "CN": "system:kube-proxy"
# "O": "system:kube-proxier"
COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT="kube-proxy"
gencert

# kube-scheduler
# "CN": "system:kube-scheduler"
# "O": "system:kube-scheduler"
COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT="kube-scheduler"
gencert

# kube-api-server
# "CN": "kubernetes"
# "O": "Kubernetes"
COMPONENT_CUSTOM_COMMAND="-hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES}"
CSR_COMPONENT="kube-api-server"
gencert

# service account
# "CN": "service-accounts"
# "O": "Kubernetes"
COMPONENT_CUSTOM_COMMAND=""
CSR_COMPONENT="service-account"
gencert