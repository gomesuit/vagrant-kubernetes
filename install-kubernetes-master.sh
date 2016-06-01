#!/bin/sh

yum install -y etcd kubernetes flannel

systemctl enable etcd
systemctl enable flanneld

cat <<EOF > /etc/etcd/etcd.conf
# [member]
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"

#[cluster]
#ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"

#[proxy]

#[security]

#[logging]
EOF

systemctl start etcd

sleep 5

etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'

systemctl start flanneld

openssl genrsa -out /etc/kubernetes/serviceaccount.key 2048


cat <<EOF > /etc/kubernetes/apiserver
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_ETCD_SERVERS="--etcd-servers=http://master01:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=172.17.0.0/16"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
KUBE_API_ARGS="--service_account_key_file=/etc/kubernetes/serviceaccount.key"
EOF

cat <<EOF > /etc/kubernetes/controller-manager
KUBE_CONTROLLER_MANAGER_ARGS="--service_account_private_key_file=/etc/kubernetes/serviceaccount.key"
EOF

cat <<EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://master01:8080"
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
