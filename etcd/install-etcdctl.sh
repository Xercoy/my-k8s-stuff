#!/bin/bash
# https://github.com/coredns/deployment/tree/master/kubernetes
set -x

# download
wget -q --show-progress --https-only --timestamping \
"https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"

# extract etcd, etcdctl binaries to PATH
tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/