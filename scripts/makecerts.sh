#!/bin/bash
set -xeuo pipefail

# cluster1
pushd certs
export ROOTCA_CN="Root CA cluster1"
make root-ca
make cluster1-certs
rm root*

# cluster2
export ROOTCA_CN="Root CA cluster2"
make root-ca
make cluster2-certs
rm root*

cp cluster1/root-cert.pem .
cat cluster2/root-cert.pem >> root-cert.pem
popd