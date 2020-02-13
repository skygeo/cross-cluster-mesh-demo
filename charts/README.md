# Charts

```bash
# Add the istio helm repod
helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.4.3/charts/
# Extract istio-init chart
helm fetch istio.io/istio-init --untar
# Extract the istio chart
helm fetch istio.io/istio --untar
```
