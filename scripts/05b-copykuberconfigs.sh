# kubeconfig files for nodes
kubecfgdir=/home/jimmy/kthw/authconfigs
for host in node-0 node-1; do
  ssh root@$host "mkdir /var/lib/{kube-proxy,kubelet}"
  scp ${kubecfgdir}/kube-proxy.kubeconfig \
    root@$host:/var/lib/kube-proxy/kubeconfig \
  scp ${kubecfgdir}/${host}.kubeconfig \
    root@$host:/var/lib/kubelet/kubeconfig
done

# kubeconfig files for controle node
scp ${kubecfgdir}/admin.kubeconfig \
  ${kubecfgdir}/kube-controller-manager.kubeconfig \
  ${kubecfgdir}/kube-scheduler.kubeconfig \
  ctlnode:~/

