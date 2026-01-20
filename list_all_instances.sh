#!/bin/bash
# curl -fsSL https://raw.githubusercontent.com/ronaldandrade-dnx/scripts/refs/heads/main/list_all_instances.sh | bash

# Cabeçalho
echo "Nome,ID,Tipo,Região"

# Lista todas as regiões disponíveis
REGIONS=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

for REGION in $REGIONS; do
  aws ec2 describe-instances \
    --region "$REGION" \
    --query 'Reservations[].Instances[].[
      Tags[?Key==`Name`].Value | [0],
      InstanceId,
      InstanceType
    ]' \
    --output text | while read NAME ID TYPE; do
      echo "${NAME:-SemNome},$ID,$TYPE,$REGION"
    done
done
