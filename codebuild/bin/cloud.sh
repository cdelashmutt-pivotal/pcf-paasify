# Include to validate cloud specified

if [ -z "$cloud" ]; then
  echo "Error: Cloud provider must be specified"
  exit 1
fi

export CLOUD_TF_DIR=$CODEBUILD_SRC_DIR/terraform/$cloud

if [ ! -d "$CLOUD_TF_DIR" ]; then
  echo "Cloud $cloud does not appear to be supported (Terraform directory not found)"
  exit 1
fi

if [ "$cloud" = "gcp" ]; then
  echo "Bootstrapping Google Cloud..."

  export TF_VAR_project=$(aws ssm get-parameter --name /paasify/gcp/project_name | jq '.Parameter.Value' -r)
  export TF_VAR_dns_zone_name=$(aws ssm get-parameter --name /paasify/gcp/dns_zone_name | jq '.Parameter.Value' -r)

  aws ssm get-parameter --name /paasify/gcp/auth.json --with-decryption | jq '.Parameter.Value' -r > /tmp/auth.json

  export GOOGLE_APPLICATION_CREDENTIALS=/tmp/auth.json
fi

if [ "$cloud" = "azure" ]; then
  echo "Bootstrapping Azure..."

  export TF_VAR_client_id=$(aws ssm get-parameter --name /paasify/azure/client_id | jq '.Parameter.Value' -r)
  export TF_VAR_client_secret=$(aws ssm get-parameter --name /paasify/azure/client_secret --with-decryption | jq '.Parameter.Value' -r)
  export TF_VAR_subscription_id=$(aws ssm get-parameter --name /paasify/azure/subscription_id | jq '.Parameter.Value' -r)
  export TF_VAR_tenant_id=$(aws ssm get-parameter --name /paasify/azure/tenant_id | jq '.Parameter.Value' -r)
fi

export TF_VAR_pivnet_token=$(aws ssm get-parameter --name /paasify/pivnet_token --with-decryption | jq '.Parameter.Value' -r)