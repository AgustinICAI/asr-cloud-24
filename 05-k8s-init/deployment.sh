#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

set_compute_zone() {
  echo "$(green_text "[+] Setting the compute zone:") $zone ..."
  gcloud config set compute/zone $zone
}

create_cluster() {
  echo "$(green_text "[+] Creating GKE cluster:") $cluster_name ..."
  gcloud container clusters create $CLUSTER_NAME \
  --enable-master-authorized-networks \
  --enable-ip-alias \
  --disk-size 35 \
  --master-authorized-networks "$(curl ifconfig.me)/32"
}

create_and_expose_deployment() {
  echo "$(green_text "[+] Creating and exposing deployment") ..."
  gcloud container clusters get-credentials $cluster_name
  #kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
  #kubectl expose deployment hello-server --type=LoadBalancer --port 8080
  kubectl create deployment mario-server --image=gcr.io/innate-infusion-327910/supermario
  kubectl expose deployment mario-server --type=LoadBalancer --port 8080
  echo "$(green_text "[+] Deployment finished succesfully! 🥳 🥳 🥳")"
}

#set_compute_zone
create_cluster
#create_and_expose_deployment






