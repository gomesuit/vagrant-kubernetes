# vagrant-kubernetes

```
cd /root/kubernetes-practice
```

## podの作成と確認
```
kubectl create -f pod-httpd.yaml
kubectl get po
kubectl get po httpd -o yaml
```

## serviceの作成と確認
```
kubectl create -f service-httpd.yaml
kubectl get svc
kubectl get svc
kubectl get svc apache -o yaml
```

## WEBサーバの動作確認
```
curl http://192.168.33.10:[NodePort]
curl http://192.168.33.20:[NodePort]
curl http://192.168.33.30:[NodePort]
```

## podとserviceの削除
```
kubectl delete -f service-httpd.yaml
kubectl delete -f pod-httpd.yaml
```


## Deploying Applications
```
kubectl create -f sample/deploying/run-my-nginx.yaml
kubectl get deployment
kubectl get pods
kubectl describe po
kubectl delete deployment/my-nginx
```

## Managing Resources
```
kubectl create -f sample/deploying/nginx-app.yaml
```

## Show endpoints
```
kubectl get ep
```

## yamlファイル変更後applyコマンドで反映
```
kubectl apply -f sample/deploying/nginx-app.yaml
```

## 直接反映
```
kubectl edit po httpd
```
