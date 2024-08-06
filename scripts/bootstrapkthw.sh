# localhost stuff
sudo chmod -x /usr/share/landscape/landscape-sysinfo.wrapper
sudo chmod -x /etc/update-motd.d/*
sudo timedatectl set-timezone America/New_York
# local directory variables
certdir=/home/jimmy/kthw/certs
cacertdir=/home/jimmy/kthw/ca
kubecfgdir=/home/jimmy/kthw/kubeconfigs
cfgfiles=/home/jimmy/kthw/configs
services=/home/jimmy/kthw/services
binaries=/home/jimmy/kthw/bin
host=ctlnode

###########
# Ctlnode #
###########
echo
echo ${host}
echo
echo -----------------
# OS Config
echo -e "\e[0;32m OS Config\n----------- \e[0m "

ssh $host sudo "sed -i 's/127.0.1.1 .*.kthw.me.*/127.0.1.1 $host.kthw.me $host/'" /etc/hosts
ssh $host sudo hostnamectl hostname $host
ssh $host sudo cp /home/jimmy/.ssh/* /root/.ssh
ssh $host sudo apt-get update
ssh $host sudo apt-get -y upgrade
ssh $host sudo chmod -x /usr/share/landscape/landscape-sysinfo.wrapper
ssh $host sudo chmod -x /etc/update-motd.d/*
ssh $host sudo timedatectl set-timezone America/New_York
sleep 2

# make directories:
echo -e "\e[0;32m OS Make Directories\n------------------ \e[0m "

ssh root@${host} mkdir -p \
    /var/lib/kubernetes \
    /etc/etcd /var/lib/etcd \
    /etc/kubernetes/config 
ssh root@${host} chmod 700 /var/lib/etcd
ssh ${host} mkdir supportfiles

# Copy files by destination directory
echo -e "\e[0;32m Copy Files\n----------- \e[0m "

# /usr/local/bin
scp \
    ${binaries}/kube-apiserver \
    ${binaries}/kube-controller-manager \
    ${binaries}/kube-scheduler \
    ${binaries}/kubectl \
    ${binaries}/etcd \
    ${binaries}/etcdctl \
    ${binaries}/etcdutl \
    root@${host}:/usr/local/bin
ssh root@${host} chmod +x /usr/local/bin/kubectl /usr/local/bin/kube-controller-manager \
	/usr/local/bin/kube-scheduler /usr/local/bin/kube-apiserver

# /var/lib/kubernetes
scp \
    ${cacertdir}/ca.key ${cacertdir}/ca.crt \
    ${certdir}/kube-api-server.key ${certdir}/kube-api-server.crt \
    ${certdir}/service-accounts.key ${certdir}/service-accounts.crt \
    ${cfgfiles}/encryption-config.yaml \
    ${kubecfgdir}/kube-controller-manager.kubeconfig \
    ${kubecfgdir}/kube-scheduler.kubeconfig \
    root@${host}:/var/lib/kubernetes

# /etc/kubernetes/config
scp \
    ${cfgfiles}/kube-scheduler.yaml \
    root@${host}:/etc/kubernetes/config

# /etc/systemd/system
scp \
    ${services}/etcd.service \
    ${services}/kube-apiserver.service \
    ${services}/kube-controller-manager.service \
    ${services}/kube-scheduler.service \
    root@${host}:/etc/systemd/system

# /home/###/supportfiles
scp \
    ${kubecfgdir}/admin.kubeconfig \
    ${cfgfiles}/kube-apiserver-to-kubelet.yaml \
    ${host}:/home/jimmy/supportfiles/
echo -e "\e[0;32m \n################### \n______________ \n HEY RIGHT HERE!!!!!!\n---------------\n########################\e[0m "
ssh ${host} kubectl apply -f /home/jimmy/supportfiles/kube-apiserver-to-kubelet.yaml --kubeconfig /home/jimmy/supportfiles/admin.kubeconfig


# Tar files
#ssh ${host} sudo tar xf /home/jimmy/supportfiles/etcd.tar.gz -C /usr/local/bin/
# ssh ${host} tar xf /home/jimmy/supportfiles/etcd.tar.gz -C ./supportfiles/
# ssh ${host} sudo mv /home/jimmy/supportfiles/etcd-v3.5.14-linux-amd64/etcd* /usr/local/bin

# Start services
echo -e "\e[0;32m Service Install\n---------------- \e[0m "

ssh ${host} sudo systemctl daemon-reload
ssh ${host} sudo systemctl enable etcd kube-apiserver kube-controller-manager kube-scheduler
ssh ${host} sudo systemctl start  etcd kube-apiserver kube-controller-manager kube-scheduler

echo -e "\e[0;32m *** ${host} Done ***\n--------------- \e[0m "

#########
# Nodes #
#########
echo -e "\e[0;32m Nodes\n------------ \e[0m "

for host in node-0 node-1; do
echo
echo ${host}
echo
echo -------------
# OS Configurations.
echo -e "\e[0;32m OS Config\n---------------- \e[0m "

ssh $host sudo "sed -i 's/127.0.1.1 .*.kthw.me .*/127.0.1.1 $host.kthw.me $host/'" /etc/hosts
ssh $host sudo hostnamectl hostname $host
ssh $host sudo cp /home/jimmy/.ssh/* /root/.ssh/
ssh $host sudo apt-get update
ssh $host sudo apt-get -y upgrade
ssh $host sudo apt-get -y install socat conntrack ipset
ssh $host sudo swapoff -a
ssh $host sudo "sed -i 's/^\/swap.img/# \/swap.img/'" /etc/fstab
ssh $host sudo chmod -x /usr/share/landscape/landscape-sysinfo.wrapper
ssh $host sudo chmod -x /etc/update-motd.d/*
ssh $host sudo timedatectl set-timezone America/New_York

# Make directories
echo -e "\e[0;32m Make Directories\n----------- \e[0m "

ssh $host sudo mkdir -p /var/lib/kube-proxy \
    /var/lib/kubelet /etc/cni/net.d \
    /opt/cni/bin /var/lib/kubelet \
    /var/lib/kube-proxy/ /var/lib/kubernetes \
    /var/run/kubernetes /etc/containerd
ssh $host mkdir /home/jimmy/supporting

# Copy Files
echo -e "\e[0;32m Copy Data\n----------- \e[0m "

scp ${cacertdir}/ca.crt root@$host:/var/lib/kubelet/
scp ${certdir}/$host.crt root@$host:/var/lib/kubelet/kubelet.crt
scp ${certdir}/$host.key root@$host:/var/lib/kubelet/kubelet.key
scp ${kubecfgdir}/kube-proxy.kubeconfig root@$host:/var/lib/kube-proxy/kubeconfig
scp ${kubecfgdir}/${host}.kubeconfig root@$host:/var/lib/kubelet/kubeconfig
scp ${binaries}/kubelet ${binaries}/kube-proxy \
    ${binaries}/runc ${binaries}/kubectl \
    root@${host}:/usr/local/bin
scp ${binaries}/crictl.tar.gz \
    ${binaries}/cni-plugins.tgz \
    ${binaries}/containerd.tar.gz \
    $host:/home/jimmy/supporting
ssh root@${host} chmod +x /usr/local/bin/*
scp ${cfgfiles}/99-loopback.conf root@${host}:/etc/cni/net.d/
scp ${cfgfiles}/${host}-bridge.conf root@${host}:/etc/cni/net.d/10-bridge.conf
scp ${cfgfiles}/containerd-config.toml root@${host}:/etc/containerd/config.toml
scp ${cfgfiles}/${host}-kubelet-config.yaml root@${host}:/var/lib/kubelet/kubelet-config.yaml
scp ${cfgfiles}/kube-proxy-config.yaml root@${host}:/var/lib/kube-proxy/
scp ${services}/containerd.service ${services}/kubelet.service \
    ${services}/kube-proxy.service \
    root@${host}:/etc/systemd/system/

echo -e "\e[0;32m tar files\n----------- \e[0m "

ssh $host sudo tar -xf /home/jimmy/supporting/crictl.tar.gz -C /usr/local/bin/
ssh $host sudo tar -xf /home/jimmy/supporting/cni-plugins.tgz --exclude='*E*' -C /opt/cni/bin/
ssh $host sudo tar -xf /home/jimmy/supporting/containerd.tar.gz --strip=1 -C /bin/
# ssh $host sudo "tar -xf /home/jimmy/supporting/containerd.tar.gz -C / --no-overwrite-dir"

echo -e "\e[0;32m Run Services\n--------------- \e[0m "
ssh $host sudo systemctl daemon-reload
ssh $host sudo systemctl enable containerd kubelet kube-proxy
ssh $host sudo systemctl start containerd kubelet kube-proxy
done

echo -e "\e[0;32m *** Nodes Done ***\n--------------- \e[0m "

########
# base #
########
echo -e "\e[0;32m *** base OS ***\n--------------- \e[0m "

kubectl config set-cluster kthw \
  --certificate-authority=../ca/ca.crt \
  --embed-certs=true \
  --server=https://ctlnode.kthw.me:6443

kubectl config set-credentials admin \
  --client-certificate=../certs/admin.crt \
  --client-key=../certs/admin.key

kubectl config set-context kthw \
  --cluster=kthw \
  --user=admin

kubectl config use-context kthw

SERVER_IP=$(grep ctlnode ~/kthw/configs/machines.txt | cut -d " " -f 1)
NODE_0_IP=$(grep node-0 ~/kthw/configs/machines.txt | cut -d " " -f 1)
NODE_0_SUBNET=$(grep node-0 ~/kthw/configs/machines.txt | cut -d " " -f 4)
NODE_1_IP=$(grep node-1 ~/kthw/configs/machines.txt | cut -d " " -f 1)
NODE_1_SUBNET=$(grep node-1 ~/kthw/configs/machines.txt | cut -d " " -f 4)

ssh root@ctlnode <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF


