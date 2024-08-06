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
