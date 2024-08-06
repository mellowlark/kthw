kubectl create secret generic kthw --from-literal="mykey=mydata"
  ssh ctlnode sudo  'etcdctl get /registry/secrets/default/kthw | hexdump -C'
kubectl create deployment nginx --image=nginx:latest
  kubectl get pods
# forbidden errors:
kubectl port-forward pod/nginx-7584b6f84c-9w89t 8080:80
  curl --head http://127.0.0.1:8080
kubectl logs $POD_NAME
kubectl exec -ti $POD_NAME -- nginx -v

# works:
curl -I http://node-X:${NODE_PORT}
