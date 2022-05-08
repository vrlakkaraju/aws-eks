#!/bin/bash
# Download and install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

# Echo helm version
helm version

# Adding Prometheus helm chart repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# List helm repo list
helm repo list

# Install Prometheus helm chart
helm install prometheus prometheus-community/prometheus
