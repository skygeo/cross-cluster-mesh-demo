#!/bin/bash
set -xuo pipefail
echo $1

export KUBECONFIG=.kubeconfig
kubectl config use-context kind-$1
ctx=kind-$1

kubectl create ns istio-system

# Add ca certificates
kubectl create secret \
    generic cacerts -n istio-system \
    --from-file=./certs/$1/ca-cert.pem \
    --from-file=./certs/$1/ca-key.pem \
    --from-file=./certs/root-cert.pem \
    --from-file=./certs/$1/cert-chain.pem \
    --context $ctx

# Install charts
helm template -name istio-init --namespace istio-system charts/istio-init | kubectl apply -f - --context $ctx
kubectl -n istio-system wait --for=condition=complete job --all --context $ctx
helm template -name istio --namespace istio-system charts/istio -f config/istio.yaml | kubectl apply -f - --context $ctx

helm template \
    --set istio.enabled=true \
    --set crosscluster.enabled=true \
    --set istio.mtls.enabled=true \
    --namespace infrabin \
    ./charts/infrabin | kubectl apply -f - --context $ctx

kubectl create ns demo --context $ctx

kubectl label ns demo istio-injection=enabled --context $ctx