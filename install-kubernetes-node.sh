#!/bin/sh

yum install -y docker kubernetes flannel

systemctl enable flanneld

cat <<EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD="http://master01:2379"
FLANNEL_ETCD_KEY="/atomic.io/network"
EOF

systemctl start flanneld
systemctl start docker

cat <<EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://master01:8080"
EOF

cat <<EOF > /etc/kubernetes/kubelet
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_API_SERVER="--api-servers=http://master01:8080"
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
KUBELET_ARGS=""
EOF

systemctl start kube-proxy
systemctl start kubelet