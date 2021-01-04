# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "my_db_subnet_group" {
    name = "${lower(local.name_prefix)}-subnet-group"
    subnet_ids = [
        aws_subnet.my_subnet_private.id,
        aws_subnet.my_subnet_public.id
    ]
    tags = merge(
        {
            "Name" = "${local.name_prefix}-subnet-group"
        },
        local.default_tags,
    )
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "my_db_instance" {
    allocated_storage = var.allocated_storage
    storage_type = "gp2"
    engine = var.engine_name
    engine_version = var.engine_version
    instance_class = var.db_instance_type
    name = var.db_name
    username = var.username
    password = var.password
    identifier =  "${lower(local.name_prefix)}-db-instance"
    storage_encrypted = true
    vpc_security_group_ids = [
        aws_security_group.my_sg_rds.id
    ]
    db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id
    multi_az = true # con multi AZ
    skip_final_snapshot = true
    tags = merge(
        {
            "Name" = "${local.name_prefix}-db-instance"
        },
        local.default_tags,
    )
}