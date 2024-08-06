# CA certs
# Note the ca.conf should be downloaded and edited if customizing steps.
cacerts () {
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ../configs/ca.conf \
    -out ca.crt
}

# Client\Server certs
certs=(
  "admin" "node-0" "node-1"
  "kube-proxy" 
  "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)

for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "../configs/ca.conf" -section ${i} \
    -out "${i}.csr"
  
  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "../ca/ca.crt" \
    -CAkey "../ca/ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
rm ca.crt ca.key
mv *.crt *.key ../certs
rm *
#Config files for authentication
ctlserver=ctlnode.kthw.me
certdir=/home/jimmy/kthw/certs
cacertdir=/home/jimmy/kthw/ca
cfgfiles=/home/jimmy/kthw/configs

# Worker node configs
for host in node-0 node-1; do
  kubectl config set-cluster kthw \
    --certificate-authority=${cacertdir}/ca.crt \
    --embed-certs=true \
    --server=https://${ctlserver}:6443 \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-credentials system:node:${host} \
    --client-certificate=${certdir}/${host}.crt \
    --client-key=${certdir}/${host}.key \
    --embed-certs=true \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-context default \
    --cluster=kthw \
    --user=system:node:${host} \
    --kubeconfig=${host}.kubeconfig

  kubectl config use-context default \
    --kubeconfig=${host}.kubeconfig
done

# The kube-proxy Kubernetes Configuration File
kubectl config set-cluster kthw \
  --certificate-authority=${cacertdir}/ca.crt \
  --embed-certs=true \
  --server=https://${ctlserver}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=${certdir}/kube-proxy.crt \
  --client-key=${certdir}/kube-proxy.key \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kthw \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-proxy.kubeconfig

# The kube-controller-manager Kubernetes Configuration File
kubectl config set-cluster kthw \
  --certificate-authority=${cacertdir}/ca.crt \
  --embed-certs=true \
  --server=https://${ctlserver}:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=${certdir}/kube-controller-manager.crt \
  --client-key=${certdir}/kube-controller-manager.key \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kthw \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-controller-manager.kubeconfig

# The kube-scheduler Kubernetes Configuration File
kubectl config set-cluster kthw \
  --certificate-authority=${cacertdir}/ca.crt \
  --embed-certs=true \
  --server=https://${ctlserver}:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=${certdir}/kube-scheduler.crt \
  --client-key=${certdir}/kube-scheduler.key \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kthw \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-scheduler.kubeconfig

# The admin Kubernetes Configuration File
kubectl config set-cluster kthw \
  --certificate-authority=${cacertdir}/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=${certdir}/admin.crt \
  --client-key=${certdir}/admin.key \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=kthw \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default \
  --kubeconfig=admin.kubeconfig

# encryption-config.yaml
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
envsubst < ${cfgfiles}/encryption-config.yaml.template \
	 > ${cfgfiles}/encryption-config.yaml

mv * ../kubeconfigs/
