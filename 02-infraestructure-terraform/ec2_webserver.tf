resource "aws_instance" "my_instance_webserver_windows" {
    associate_public_ip_address = false  # no asignar una ip pública
    disable_api_termination = false # para terminarlo desde la api
    ami = data.aws_ami.my_ami_windows.id    # asignar la ami (se ha reutilizado la misma del jumpbox)
    instance_type = var.instance_type
    # user_data = ""
    key_name = aws_key_pair.my_key.key_name # asignar el keypair
    iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name    # asignar rol profile para s3
    vpc_security_group_ids = [
        aws_security_group.my_sg_ec2.id
    ]
    subnet_id = aws_subnet.my_subnet_private.id
    instance_initiated_shutdown_behavior = "stop"    # inicie como detenida
    tags = merge(
        {
            "Name" = "${local.name_prefix}-instance-web-windows"
        },
        local.default_tags,
    )
}

resource "aws_instance" "my_instance_webserver_ubuntu" {
    associate_public_ip_address = false  # no asignar una ip pública
    disable_api_termination = false # para terminarlo desde la api
    ami = data.aws_ami.my_ami_ubuntu.id    # asignar la ami (se ha reutilizado la misma del autoscaling group)
    instance_type = var.instance_type
    # user_data = ""
    key_name = aws_key_pair.my_key.key_name # asignar el keypair
    iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name    # asignar rol profile para s3
    vpc_security_group_ids = [
        aws_security_group.my_sg_ec2.id
    ]
    subnet_id = aws_subnet.my_subnet_private.id
    instance_initiated_shutdown_behavior = "stop"    # inicie como detenida
    tags = merge(
        {
            "Name" = "${local.name_prefix}-instance-web-ubuntu"
        },
        local.default_tags,
    )
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "${local.name_prefix}-bucket"
    acl = "private"
}