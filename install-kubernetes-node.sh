#!/bin/sh

yum install -y kubernetes-node

tee /etc/kubernetes/config <<-EOF
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=10"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://master01:8080"
#KUBE_ETCD_SERVERS="--etcd_servers=http://master01:2379"
EOF

tee /etc/kubernetes/kubelet <<-EOF
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_API_SERVER="--api-servers=http://master01:8080"
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
KUBELET_ARGS="--register-node=true"
EOF

tee /etc/kubernetes/proxy <<-EOF
KUBE_PROXY_ARGS="--proxy-mode=iptables"
EOF

systemctl start docker
systemctl start kube-proxy
systemctl start kubelet
systemctl enable docker
systemctl enable kube-proxy
systemctl enable kubelet
