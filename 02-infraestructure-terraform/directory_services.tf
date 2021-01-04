# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_directory
resource "aws_directory_service_directory" "my_directory_service" {
    name = var.domain_name
    password = "Tecsup123"  # Se recomienda no hardcodear y utilizar un key vault
    type = var.dir_type # "SimpleAD"
    # edition = "Standard"  # Aplica solo para tipos MicrosoftAD 
    description = "${local.name_prefix}-service-directory"
    vpc_settings {
        vpc_id = aws_vpc.my_vpc.id
        subnet_ids = [   # Requiere 2 subnets en diferentes zonas por alta disponibilidad
            aws_subnet.my_subnet_private.id,
            aws_subnet.my_subnet_public.id
        ]
    }
    lifecycle {
        ignore_changes = [
            edition,    # Ignore changes to edition, Because for some reason it wants to recreat it always
        ]
    }
}