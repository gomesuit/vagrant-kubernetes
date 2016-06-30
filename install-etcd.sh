#!/bin/sh

yum install -y etcd

tee /etc/etcd/etcd.conf <<-EOF
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_LISTEN_PEER_URLS="http://localhost:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"
#ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
EOF

systemctl start etcd
systemctl enable etcd

sleep 5

tee ~/flannel.json <<-EOF
{
    "Network": "10.2.0.0/16",
    "Backend": {
        "Type": "vxlan"
    }
}
EOF

etcdctl set /atomic.io/network/config < ~/flannel.json
