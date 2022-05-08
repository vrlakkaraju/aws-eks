#!/bin/bash
# Download and install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

# Echo helm version
helm version

# Adding Prometheus helm chart repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install Prometheus helm chart
helm install prometheus prometheus-community/prometheus

# By default, installing prometheus helm chart creates prometheus-server clusterIP service so in-order to access the prometheus web UI over the internet, exposing clusterIP service as NodePort serice
export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl expose pod $POD_NAME --type=NodePort --target-port=9090 --name=prometheus-server-ext
echo "Promtheus server related NodePort service: $(kubectl get svc|grep -i ext)"
echo -e "\n##########################################################################\n"
echo -e "\nMAKE SURE TO OPEN EKS NODE SG to ALLOW NODEPORT serice port from 0.0.0.0/0"
echo -e "\n##########################################################################\n"

# Adding Grafana helm chart repo
helm repo add grafana https://grafana.github.io/helm-charts

# Install Grafana helm chart
helm install grafana grafana/grafana

#By default, installing grafana helm chart creates grafana clusterIP service so in-order to access the grafana web UI over the internet, exposing clusterIP service as NodePort serice
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext
echo -e "\n##########################################################################\n"
echo -e "\nMAKE SURE TO OPEN EKS NODE SG to ALLOW NODEPORT serice port from 0.0.0.0/0"
echo -e "\n##########################################################################\n"

# Now get Grafana username and password so you can configure grafana dashboard by navigating to web UI at http:<NodeIP>:<NodePort_svc_port>, below are commands to get username and password
echo "Grafana admin user password: $(kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)"
echo "Grafana admin username: $(kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo)"


echo -e "\n Add the prometheus datasource by http://<NodeIP:<Prometheus-server-ext_NodePort_svc_port>>"
echo -e "\n You can also import Kubernetes cluster grafana dashboard ID 6417 from https://grafana.com/grafana/dashboards/6417"

# List helm repo list
helm repo list

