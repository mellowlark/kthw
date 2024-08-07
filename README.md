# Kubernetes The Hard Way

This tutorial walks you through setting up Kubernetes the hard way. Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Copyright

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

The bulk of this material was copied from <a href="https://github.com/kelseyhightower/kubernetes-the-hard-way"> Kubernetes the hard way</a> and and shuffled around to fit my personal style.


## Target Audience

The target audience for this tutorial is someone who wants to understand the fundamentals of Kubernetes and how the core components fit together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a basic Kubernetes cluster with all control plane components running on a single node, and two worker nodes, which is enough to learn the core concepts.

Component versions:

* [kubernetes](https://github.com/kubernetes/kubernetes)
* [containerd](https://github.com/containerd/containerd)
* [cni](https://github.com/containernetworking/cni)
* [etcd](https://github.com/etcd-io/etcd) 

## Labs

This tutorial requires four (4) virtual or physical machines connected to the same network. 

* [Prerequisites](begin here/01-prerequisites.md)
* [Setting up the Jumpbox](begin here/02-jumpbox.md)
* [Provisioning Compute Resources](begin here/03-compute-resources.md)
* [Provisioning the CA and Generating TLS Certificates](begin here/04-certificate-authority.md)
* [Generating Kubernetes Configuration Files for Authentication](begin here/05-kubernetes-configuration-files.md)
* [Generating the Data Encryption Config and Key](begin here/06-data-encryption-keys.md)
* [Bootstrapping the etcd Cluster](begin here/07-bootstrapping-etcd.md)
* [Bootstrapping the Kubernetes Control Plane](begin here/08-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Kubernetes Worker Nodes](begin here/09-bootstrapping-kubernetes-workers.md)
* [Configuring kubectl for Remote Access](begin here/10-configuring-kubectl.md)
* [Provisioning Pod Network Routes](begin here/11-pod-network-routes.md)
* [Smoke Test](begin here/12-smoke-test.md)
* [Cleaning Up](begin here/13-cleanup.md)
