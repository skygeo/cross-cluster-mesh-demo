# How skyscanner moved to multi cluster mesh with istio

Devops meetup Edi. This is a quick overview of how skyscanner moved to multi-cluster mesh using istio.


1. Install kind and helm

    https://github.com/kubernetes-sigs/kind#installation-and-usage
    https://helm.sh/docs/intro/install/


1. Create two clusters
    ```bash
    # Create two kubernetes clusters

    kind create cluster\
      --name cluster1 \
      --config ./config/kind-cluster1.yaml \
      --kubeconfig .kubeconfig

    kind create cluster\
      --name cluster2 \
      --config ./config/kind-cluster2.yaml \
      --kubeconfig .kubeconfig

    # Set your local kubeconfig
    export KUBECONFIG=$(pwd)/.kubeconfig
    ```

1. generate istio certificates

    ```bash
    cd certs
    make root-ca
    make cluster-certs
    ```

1. install istio on both cells
    ```bash
    # create namespace
    kubectl create ns istio-system
    # Add ca certificates
    kubectl create secret generic cacerts -n istio-system --from-file=./certs/cluster/ca-cert.pem --from-file=./certs/cluster/ca-key.pem --from-file=./certs/cluster/root-cert.pem --from-file=./certs/cluster/cert-chain.pem
    # Install charts
    helm template -name istio-init --namespace istio-system charts/istio-init | kubectl apply -f -
    kubectl -n istio-system wait --for=condition=complete job --all
    helm template -name istio --namespace istio-system charts/istio -f config/istio.yaml | kubectl apply -f -
    ```

1. Deploy our test app
    ```bash
      helm template --namespace infrabin ./charts/infrabin | kubectl apply -f -
    ```

1. Add http gateway

    ```bash
        helm template --set istio.enabled=true --namespace infrabin ./charts/infrabin | kubectl apply -f -
    ```

1. Make it work cross cluster

    ```bash
        helm template --set istio.enabled=true --set crosscluster.enabled=true --namespace infrabin ./charts/infrabin | kubectl apply -f -
    ```

1. Full mutual TLS on the gateway

    ```bash
        helm template --set istio.enabled=true --set crosscluster.enabled=true --set istio.mtls=true --namespace infrabin ./charts/infrabin | kubectl apply -f -
    ```
    
**testing***

    ```bash
        # from an injected pod
        # direct
        curl infrabin.infrabin/headers | jq .
        # via the gateways
        curl infrabin.example.com/headers --resolve infrabin.example.com:80:1.2.3.4 | jq .
    ```

**For more details**

1. Kind Documentation
    https://kind.sigs.k8s.io/docs/user/quick-start/
1. Istio docs
    https://istio.io/docs/
1. k9s
    https://github.com/derailed/k9s
