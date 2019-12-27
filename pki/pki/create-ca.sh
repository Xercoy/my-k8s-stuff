#!/bin/bash
# create a certificate authority
# trading flexibility and defaults
# for automation and learning.

# todos
# make more flexible
# don't overwrite already existing CAs

CSR_FILE_PATH=$1
CSR_DEFAULT_FILE_NAME="default-ca-csr.json"
CA_NAME=$2

# without args, generate a CA CSR and create
# the CA which results in a cert, private key, and csr
if [[ "${CA_NAME}" == "" && "${CSR_FILE_PATH}" == "" ]]; then
    CA_NAME="ca"

    read -r -d '' CSR <<EOM
    {
        "CN": "Kubernetes",
        "key": {
            "algo": "rsa",
            "size": 2048
        },
        "names": [
            {
                "C": "USA",
                "L": "Los Angeles",
                "O": "Kubernetes",
                "OU": "CA",
                "ST": "California"
            }
        ]
    }
EOM
  
    echo "${CSR}" > "${CSR_DEFAULT_FILE_NAME}"
    CSR_FILE_PATH="./${CSR_DEFAULT_FILE_NAME}"

    echo "created default CA at ${CSR_FILE_PATH}"
fi

cfssl gencert -initca "${CSR_FILE_PATH}" | cfssljson -bare "${CA_NAME}"
echo "created CA named ${CA_NAME}"
