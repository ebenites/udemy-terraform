# AWS Credentials
aws configure

# AWS Credentials with Profile
aws configure --profile pe-interbank-ml-development

aws configure list

provider "aws" {
  profile = "pe-interbank-ml-development"
  region = "us-east-1"
  version = "~> 3.22"
}

# Terraform plan with specific tfvars
terraform plan --var-file=./tfvars.json

# Terraform apply with specific tfvars
terraform apply --var-file=./tfvars.json

# Terraform destroy with specific tfvars
terraform destroy --var-file=./tfvars.json
