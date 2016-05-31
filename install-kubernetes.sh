#!/bin/sh

yum install -y etcd kubernetes flannel

systemctl enable etcd
systemctl enable flannel
