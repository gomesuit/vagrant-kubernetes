#!/bin/sh

NODENAME=$1
BIND_ADDRESS=$2
JOIN=$3

echo $NODENAME
echo $BIND_ADDRESS
echo $JOIN

mkdir -p /root/consul.d

cat <<EOF > /root/consul.d/agent.json
{
	"ports": {
		"dns": 53
	},
	"recursor": "8.8.8.8"
}
EOF

/usr/local/bin/consul agent \
	-config-dir=/root/consul.d \
	-data-dir=/tmp/consul \
	-node=$NODENAME \
	-server \
	-dc=local \
	-bind=$BIND_ADDRESS \
	-join=$JOIN \
	-bootstrap-expect=2 \
	 > /dev/null 2>&1 &
