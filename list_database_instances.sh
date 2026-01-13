#!/usr/bin/env bash 
# nano list_database_instances.sh 
# chmod +x list_database_instances.sh 
# ./list_database_instances.sh
set -euo pipefail

OUTPUT="rds_inventory_all_regions.csv"

# Dados da conta
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

ACCOUNT_NAME=$(aws organizations describe-account \
  --account-id "$ACCOUNT_ID" \
  --query 'Account.Name' \
  --output text 2>/dev/null || echo "N/A")

# Header do CSV
echo "CONTA ID,regiao,id_database,engine,versao_engine,tipo_instancia,retencao_backup_dias,AZ,id_cluster_db,criado_em" > "$OUTPUT"

# Descobre todas as regiões
REGIONS=$(aws ec2 describe-regions \
  --query "Regions[].RegionName" \
  --output text)

for REGION in $REGIONS; do
  echo "➡ Coletando RDS na região: $REGION"

  aws rds describe-db-instances \
    --region "$REGION" \
    --query "DBInstances[].[
      '$ACCOUNT_ID',
      '$REGION',
      DBInstanceIdentifier,
      Engine,
      EngineVersion,
      DBInstanceClass,
      BackupRetentionPeriod,
      AvailabilityZone,
      DBClusterIdentifier,
      InstanceCreateTime
    ]" \
    --output text 2>/dev/null | \
  awk -F'\t' 'BEGIN { OFS="," }
  {
    split($10, d, "T");
    split(d[1], ymd, "-");
    created_at = ymd[3] "/" ymd[2] "/" ymd[1];
    $10 = created_at;
    print
  }'>> "$OUTPUT"

done

echo "Inventário final gerado em: $OUTPUT"
cat "$OUTPUT"
