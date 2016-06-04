#!/bin/sh

curl -O http://storage.googleapis.com/kubernetes-release/release/v1.2.0-alpha.7/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl


