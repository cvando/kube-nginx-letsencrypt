#!/bin/bash

CERTFILE=$(ls /etc/kubernetes/ssl/ | grep kube-etcd-.*[0-9].pem)
KEYFILE=$(ls /etc/kubernetes/ssl/ | grep kube-etcd-.*[0-9]-key.pem)

CERTPATH=/etc/kubernetes/ssl/$CERTFILE
KEYPATH=/etc/kubernetes/ssl/$KEYFILE


cat /secret-patch-template.json | \
	sed "s/CA/$(cat /etc/kubernetes/ssl/kube-ca.pem | base64 | tr -d '\n')/" | \
	sed "s/CERT/$(cat $CERTPATH | base64 | tr -d '\n')/" | \
	sed "s/KEY/$(cat $KEYPATH |  base64 | tr -d '\n')/" \
	> /secret-patch.json

echo "Create secret"
RESPCODE=`curl -s -o /dev/null -w '%{http_code}' --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -k -XPOST  -H "Accept: application/json, */*" -H "Content-Type: application/json" -d @/secret-patch.json https://kubernetes.default/api/v1/namespaces/storageos/secrets`


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
