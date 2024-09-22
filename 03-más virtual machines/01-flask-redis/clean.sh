#!/bin/bash

source "${PWD}/config.ini"
source "color.sh"

delete_servers() {
  echo "$(red_text "[-] Deleting VMs")..."
  gcloud compute instances list | grep RUNNING | awk '{printf "gcloud compute instances delete %s --zone %s --quiet\n", $1, $2}' | bash
  echo "$(red_text "[-] Deleting VMs ") done!"
}

delete_firewall_rules() {
  echo "$(red_text "[-] Deleting firewall rules") ..."
  gcloud compute firewall-rules list | grep -v "NAME" | awk '{printf "gcloud compute firewall-rules delete %s --quiet\n",$1}' | bash

  echo "$(red_text "[-] Deleting firewall rules ") done!"
}


delete_firewall_rules
delete_servers
