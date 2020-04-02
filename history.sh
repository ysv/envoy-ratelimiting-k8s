#!/usr/bin/env bash

helm install my-nginx stable/nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml

kubectl apply --namespace -f envoy-ingress.yaml
helm upgrade my-envoy charts/envoy --install

helm upgrade my-ratelimit charts/ratelimit --install

helm upgrade my-sample-service-1 charts/sample-service --install
helm upgrade my-sample-service-2 charts/sample-service --install

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager-legacy.crds.yaml
kubectl apply -f cert-manager-cluster-issuer.yaml
helm upgrade my-cert-manager charts/cert-manager --version v0.14.1 --install
