#!/bin/bash
for lg in $(aws logs describe-log-groups \
  --query 'logGroups[].logGroupName' \
  --output text); do
 
  # aws logs list-tags-log-group --log-group-name "$lg"

  aws logs tag-log-group \
    --log-group-name "$lg" \
    --tags Environment=$lg
done
