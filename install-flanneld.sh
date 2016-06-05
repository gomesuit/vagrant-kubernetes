#!/bin/sh

yum install -y flannel

cat <<EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD="http://master01:2379"
FLANNEL_ETCD_KEY="/atomic.io/network"
FLANNEL_OPTIONS="--iface=eth1"
EOF

systemctl start flanneld
systemctl enable flanneld
