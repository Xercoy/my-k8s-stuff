

Resources for my learning and knowledge in Kubernetes as I prepare to take the Certified Kubernetes Administrator exam. Also going through Kubernetes the Hard Way so most of the content and scripts are based from that.

Most of this work is done on Digital Ocean droplets.

## 12/27/2019

Continued to flesh out TLS cert generation from the SEVEN CSRs that I had already automated for the kubeapiserver (kubernetes), service accounts, kubelet, kube-proxy, kube-scheduler, kube-controller-manager, and admin.

Spent most of the day setting up kubeconfig generation for the FIVE components that talk to the kube-api-server: kube-scheduler, admin, kube-controller-manager, kubelet, and kube-proxy.

Etcd utilizes the same certs that the kube-api-server uses. Standing it up is a bit involved, as an etcd cluster consists of three nodes. Since I'm doing this on Digital Ocean, things have been modified to make it stand on just one node. I'll focus on a multicluster node later.

**Issues** - I realized that the kubeconfig user cert and key is different from the certificate authority's cert and key. Think this was from tunnel vision. I also had a ton of trouble initially trying to diagnose etcd issues that seemed to come from the hostnames/IPs that were allowed on the certs that were generated, additionally, trying to get around not providing an internal IP.

## 12/28/2019

Constantly making changes to the scripts to ensure that a new master node can be bootstrapped from the cluster scripts as expected.

Today's gotchas:

- need to ensure the name of the etcd instance is included in the cluster in the --intial-cluster option

- TLS generation not include the hostname option. ETCD was screaming at me that the cert had no IP SANs - had to go through things step by step and make sure.
