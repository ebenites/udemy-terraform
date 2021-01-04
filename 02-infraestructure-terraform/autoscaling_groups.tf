# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "my_private_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "my_key" {   # en producción, se recomienda crearlo manual en aws
    key_name = "${local.name_prefix}-key"
    public_key = tls_private_key.my_private_key.public_key_openssh
}

data "aws_ami" "my_ami_ubuntu" {    # para obtener la versión más reciente de ubuntu
    most_recent = true  # buscar la versión más reciente
    owners = [  # que sea propietario "amazon"
        "amazon"
    ]
    filter {    # filtrar por nombre 
        name = "name"
        values = [
            "ubuntu-bionic-18.04-amd64-server-*"
        ]
    }
}

resource "aws_launch_configuration" "my_launch_configuration" {
    name_prefix = "${local.name_prefix}-launch-configuration"
    image_id = data.aws_ami.my_ami_ubuntu.image_id
    instance_type = var.instance_type
    # user_data = ""
    associate_public_ip_address = false # no se le asigna public ip adress, son instancias ingternas
    iam_instance_profile = aws_iam_instance_profile.my_instance_profile.name
    security_groups = [
        aws_security_group.my_sg_ec2.id
    ]
    key_name = aws_key_pair.my_key.key_name # si el keypair ya existe en aws, solo indicar el nombre en comillas
    root_block_device {
        volume_size = "20"
        volume_type = "gp2"
        delete_on_termination = true    # se eliminan el volumen al terminar
    }
    lifecycle {
        create_before_destroy = true    # si hay un cambio en este launch configuration, primero se crea uno nuevo y luego se destruye este
    }
}

resource "aws_autoscaling_group" "my_asg" {
    name_prefix = "${local.name_prefix}-asg"
    launch_configuration = aws_launch_configuration.my_launch_configuration.id
    vpc_zone_identifier = [ # utilizar ambas subredes en zonas distintas
        aws_subnet.my_subnet_private.id,
        aws_subnet.my_subnet_public.id
    ]
    min_size = "2"  # cantidad de instancias mínimas
    max_size = "4"  # cantidad de instancias máximas
    health_check_type = "EC2" # tipo de health check instancias EC2
    lifecycle {
        create_before_destroy = true    # si hay un cambio en este autoscaling group, primero se crea uno nuevo y luego se destruye este
    }
    tags = local.asg_default_tags
}

# vincular autoscaling group con el target group
resource "aws_autoscaling_attachment" "my_asg_attach" {
    autoscaling_group_name = aws_autoscaling_group.my_asg.name
    alb_target_group_arn = aws_lb_target_group.my_target_group.arn
}
