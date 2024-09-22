#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"


create_firewall_rules() {
  echo "$(green_text "[+] Opening ports: $app_port") ..."

  gcloud compute firewall-rules create "default-allow-onlymyip-$app_port" \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:"$app_port" \
      --source-ranges=$(curl ifconfig.me) \
      --target-tags=app-server

  gcloud compute firewall-rules create "allow-server-to-redis-$redis_port" \
      --direction=INGRESS \
      --priority=1001 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:"$redis_port" \
      --source-tags=app-server \
      --target-tags=redis-server

    echo "$(green_text "[+] Opening ports:") done!"
}

deploy_redis_server() {
  echo "$(green_text "[+] Creating VM:") $redis_server (img: ${redis_image}) ..."
  gcloud compute instances create-with-container $redis_server \
      --machine-type="$machine_type" \
      --container-image="$redis_image" \
      --tags=redis-server \
#      --network-interface=no-address \
      --quiet
  echo "$(green_text "[+] Deploying:") $redis_server done!"
}

build_and_deploy_app() {
  REDIS_VM_IP=$(gcloud compute instances describe $redis_server --format='get(networkInterfaces[0].networkIP)')

  echo "$(green_text "[+] Building docker image:") $app_image_uri"
  docker build --tag $app_image_uri \
      --build-arg REDIS_IP=$REDIS_VM_IP \
      .

  echo "$(green_text "[+] Publishing docker image:") $app_image_uri"
  docker push "$app_image_uri"

  echo "$(green_text "[+] Deploying App:") $app_name [connected to redis IP: $REDIS_VM_IP]"
  
  REDIS_VM_IP=$(gcloud compute instances list | grep redis | awk '{print $4}')
  
  gcloud compute instances create-with-container $app_name \
      --machine-type=$machine_type \
      --container-image=$app_image_uri \
      --tags=app-server \
      --container-env="REDIS_IP_GCP=$REDIS_VM_IP" \
      --quiet

  echo "$(green_text "[+] Deployment finished succesfully! 🥳 🥳 🥳")"
}


gcloud config set compute/region europe-southwest1
gcloud config set compute/zone europe-southwest1-b 
gcloud services enable artifactregistry.googleapis.com
gcloud artifacts repositories create $REGISTRY_NAME \
    --repository-format=docker \
    --location=europe-southwest1 \
    --description="Repo docker practica 4"
gcloud auth configure-docker \
    europe-southwest1-docker.pkg.dev --quiet

create_firewall_rules
deploy_redis_server
build_and_deploy_app



