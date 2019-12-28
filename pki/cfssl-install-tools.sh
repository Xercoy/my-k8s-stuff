#!/bin/bash
# install tools required to generate and setup PKI Infrastructure

curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
chmod +x cfssl

curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
chmod +x cfssljson

curl -L https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o cfssl-certinfo
chmod +x cfssl-certinfo

mv cfssl cfssljson cfssl-certinfo /usr/local/bin
