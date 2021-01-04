# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "my_alb" {
    name = "${local.name_prefix}-alb"
    internal = true # Balanceador tipo interno (solo accesible dentro de la VPC)
    load_balancer_type = "application" # Tipo Application Load Balancer
    idle_timeout = 600
    security_groups = [
        aws_security_group.my_sg_alb.id
    ]
    subnets =[
        aws_subnet.my_subnet_public.id,
        aws_subnet.my_subnet_private.id
    ]
    enable_deletion_protection = false
    tags = merge(
        {
            "Name" = "${local.name_prefix}-alb"
        },
        local.default_tags,
    )
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "my_target_group" {
    name = "${local.name_prefix}-tg"
    port = "80"
    protocol = "HTTP"
    vpc_id = aws_vpc.my_vpc.id
    target_type = "instance"
    lifecycle {
        create_before_destroy = true # Si se modifica el target group, primero se crea uno nuevo y luego se elimina este
        ignore_changes = [  # Se puede indicar que cambios en atributos no provocará la recreación de este target group
            name
        ]
    }
    health_check {
        interval = 30   # cada 30 segundos
        healthy_threshold = 2  # 2 respuestas correctas para indicar que está activo
        unhealthy_threshold = 2    # 2 respuestas fallidas para indicar que está inactivo
        timeout = 5 # tiempo de espera máximo de 5 segundos
        matcher = "200" # código http esperado 200
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-tg"
        },
        local.default_tags,
    )
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "my_listener" {
    load_balancer_arn = aws_lb.my_alb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.my_target_group.arn
    }
}


# ALB: https://medium.com/swlh/aws-what-is-load-balancing-cc087f7b26d8