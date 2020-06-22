# How skyscanner moved to multi cluster mesh with istio

Devops meetup Edi. This is a quick overview of how skyscanner moved to multi-cluster mesh using istio.


1. Install kind and helm

    https://github.com/kubernetes-sigs/kind#installation-and-usage
    https://helm.sh/docs/intro/install/

## The quick demo

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

1. Generate certificates

    ```bash
    # Generate certs for each clusters with unique root ca
    ./script/makecerts.sh
    ```

1. Provision everything

    ```bash
    ./scripts/provision cluster1
    ./scripts/provision cluster2
    ```

**For more details**

1. Kind Documentation
https://kind.sigs.k8s.io/docs/user/quick-start/
