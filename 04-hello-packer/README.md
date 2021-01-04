# AWS Credentials
aws configure

# Packer
packer validate my-ubuntu.json

packer build my-ubuntu.json

* Verificar el id del ami recientemente creado con packer

# Terraform
terraform init

terraform plan

terraform apply

* Luego de aplicar, verificar mediante la ip pública que el servicio nginx esté corriendo

terraform destroy
