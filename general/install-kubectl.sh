#!/bin/bash

# download the binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# change cli permissions and move to usr local bin 
chmod +x kubectl
mv kubectl /usr/local/bin

echo "kubectl installation completed"

# display version
kubectl version