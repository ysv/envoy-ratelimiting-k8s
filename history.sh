#!/usr/bin/env bash

helm install my-nginx stable/nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml

kubectl apply --namespace -f envoy-ingress.yaml
helm upgrade my-envoy charts/envoy --install

helm upgrade my-sample-service-1 charts/sample-service --install
helm upgrade my-sample-service-2 charts/sample-service --install

##!/usr/bin/env bash
#
#set -e
#./bin/precheck.sh
#set -xe
#
#helm upgrade cf-front config/charts/cf-front \
#  --install \
#  --values config/environments/production/cf-front.yaml



