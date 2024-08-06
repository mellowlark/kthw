# Client\Server certs
certs=(
  "admin"
)

for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 2048

  openssl req -new -key "${i}.key" -sha256 \
    -config "../ca.conf" -section ${i} \
    -out "${i}.csr"
  
  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "../ca/ca.crt" \
    -CAkey "../ca/ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
