#!/bin/sh

yum install -y etcd

cat <<EOF > /etc/etcd/etcd.conf
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://localhost:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
EOF

systemctl start etcd
systemctl enable etcd

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
