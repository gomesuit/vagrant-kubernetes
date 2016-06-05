#!/bin/sh

yum install -y etcd kubernetes flannel

systemctl enable etcd
systemctl enable flanneld

cat <<EOF > /etc/etcd/etcd.conf
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://localhost:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
EOF

cat <<EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD="http://master01:2379"
FLANNEL_ETCD_KEY="/atomic.io/network"
FLANNEL_OPTIONS="--iface=eth1"
EOF

systemctl start etcd

sleep 5

cat <<EOF > ~/flannel.json
{
    "Network": "10.20.0.0/16",
    "SubnetLen": 24,
    "Backend": {
        "Type": "vxlan",
        "VNI": 1
    }
}
EOF

etcdctl set /atomic.io/network/config < ~/flannel.json

systemctl start flanneld

openssl genrsa -out /etc/kubernetes/serviceaccount.key 2048


cat <<EOF > /etc/kubernetes/apiserver
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_ETCD_SERVERS="--etcd-servers=http://master01:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
#KUBE_SERVICE_ADDRESSES="--portal_net=172.16.0.0/16"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
KUBE_API_ARGS="--service_account_key_file=/etc/kubernetes/serviceaccount.key"
EOF

cat <<EOF > /etc/kubernetes/controller-manager
KUBE_CONTROLLER_MANAGER_ARGS="--service_account_private_key_file=/etc/kubernetes/serviceaccount.key"
KUBELET_ADDRESSES="--machines=node01,node02"
EOF

cat <<EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://master01:8080"
#KUBE_ETCD_SERVERS="--etcd_servers=http://master01:2379"
EOF

cat <<EOF > /etc/kubernetes/proxy
KUBE_PROXY_ARGS="--master=http:///master01:8080"
EOF

systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kube-proxy

kubectl config set-credentials myself --username=admin --password=admin
kubectl config set-cluster local-server --server=http://master01:8080
kubectl config set-context default-context --cluster=local-server --user=myself
kubectl config use-context default-context
kubectl config set contexts.default-context.namespace default

kubectl cluster-info


yum install -y git
cd ~
git clone https://gomesuit@github.com/gomesuit/kubernetes-practice.git

