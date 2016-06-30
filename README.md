# vagrant-kubernetes

```
cd /root/kubernetes-practice
```

# podの作成と確認
```
kubectl create -f pod-httpd.yaml
kubectl get po
kubectl get po httpd -o yaml
```

# serviceの作成と確認
```
kubectl create -f service-httpd.yaml
kubectl get svc
kubectl get svc
kubectl get svc apache -o yaml
```

# WEBサーバの動作確認
```
curl http://192.168.33.10:[NodePort]
curl http://192.168.33.20:[NodePort]
curl http://192.168.33.30:[NodePort]
```
