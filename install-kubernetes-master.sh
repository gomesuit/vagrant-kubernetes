#!/bin/sh

yum install -y kubernetes

#openssl genrsa -out /etc/kubernetes/serviceaccount.key 2048

tee /etc/kubernetes/config <<-EOF
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=10"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://master01:8080"
EOF

tee /etc/kubernetes/apiserver <<-EOF
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_ETCD_SERVERS="--etcd-servers=http://master01:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.3.0.0/24"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,LimitRanger,ResourceQuota"
KUBE_API_ARGS="--secure-port=0"
EOF

tee /etc/kubernetes/controller-manager <<-EOF
#KUBE_CONTROLLER_MANAGER_ARGS="--service_account_private_key_file=/etc/kubernetes/serviceaccount.key"
EOF

tee /etc/kubernetes/proxy <<-EOF
KUBE_PROXY_ARGS="--proxy-mode=iptables"
EOF

systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kube-proxy
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable kube-proxy

kubectl config set-credentials myself --username=admin --password=admin
kubectl config set-cluster local-server --server=http://master01:8080
kubectl config set-context default-context --cluster=local-server --user=myself
kubectl config use-context default-context
kubectl config set contexts.default-context.namespace default

kubectl cluster-info


# install kubernetes-dashboard
kubectl create namespace kube-system
#kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
#kubectl create -f https://rawgit.com/kubernetes/dashboard/v1.0.1/src/deploy/kubernetes-dashboard.yaml
