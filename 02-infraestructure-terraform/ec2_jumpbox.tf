data "aws_ami" "my_ami_windows" {
    most_recent = true  # buscar la versión más reciente
    owners = [  # que sea propietario "amazon" o "801119661308"
        "801119661308"
    ]
    filter {
        name   = "name"
        values = ["Windows_Server-2016-English-Full-HyperV-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "my_instance_jumpbox" {
    associate_public_ip_address = true  # asignar una ip pública
    disable_api_termination = false # para terminarlo desde la api
    ami = data.aws_ami.my_ami_windows.id    # asignar la ami
    instance_type = var.instance_type
    # user_data = ""
    key_name = aws_key_pair.my_key.key_name # asignar el keypair
    iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name    # asignar rol profile para s3
    vpc_security_group_ids = [
        aws_security_group.my_sg_jumpbox.id
    ]
    subnet_id = aws_subnet.my_subnet_public.id
    instance_initiated_shutdown_behavior = "stop"    # inicie como detenida
    tags = merge(
        {
            "Name" = "${local.name_prefix}-instance-jumpbox"
        },
        local.default_tags,
    )
}