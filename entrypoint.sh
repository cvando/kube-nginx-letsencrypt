#!/bin/bash

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
CA=$(cat /etc/kubernetes/ssl/kube-ca.pem | base64)
CERT=$(cat /etc/kubernetes/ssl/kube-etcd-192-168-[0-9]*-[0-9]*.pem | base64)
KEY=$(cat /etc/kubernetes/ssl/kube-etcd-192-168-[0-9]*-[0-9]*-key.pem | base64)

sed -i "s|CA|${CA}|g" /secret-patch.json 
sed -i "s|CERT|${CERT}|g" /secret-patch.json
sed -i "s|KEY|${KEY}|g" /secret-patch.json


echo "Create secret"
RESP=`curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -k -v -XPOST  -H "Accept: application/json, */*" -H "Content-Type: application/json" -d @/secret-patch.json https://kubernetes.default/api/v1/namespaces/storageos/secrets`
echo $RESPCODE=`echo $RESP | jq -r '.code'`

case $RESPCODE in
200)
	echo "Secret Created"
	exit 0
	;;
*)
	echo "Unknown Error:"
	echo $RESP
	exit 1
	;;
esac
