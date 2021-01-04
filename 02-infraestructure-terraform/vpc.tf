resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = merge(
        {
            "Name" = "${local.name_prefix}-vpc"
        },
        local.default_tags,
    )
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = merge(
        {
            "Name" = "${local.name_prefix}-igw"
        },
        local.default_tags,
    )
}

resource "aws_subnet" "my_subnet_public" {
    map_public_ip_on_launch = true
    availability_zone = element(var.az_names, 0)
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = element(var.subnet_cidr_blocks, 0)
    tags = merge(
        {
            "Name" = "${local.name_prefix}-subnet_pub_${element(var.az_names, 0)}"
        },
        local.default_tags,
    )
}

resource "aws_subnet" "my_subnet_private" {
    map_public_ip_on_launch = false
    availability_zone = element(var.az_names, 1)
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = element(var.subnet_cidr_blocks, 1)
    tags = merge(
        {
            "Name" = "${local.name_prefix}-subnet_prv_${element(var.az_names, 1)}"
        },
        local.default_tags,
    )
}

resource "aws_eip" "my_eip" {
    
}

resource "aws_nat_gateway" "my_ngw" {
    subnet_id = aws_subnet.my_subnet_public.id
    allocation_id = aws_eip.my_eip.id   # Nat Gateway requiere de un Elastic IP
    tags = merge(
        {
            "Name" = "${local.name_prefix}-ngw"
        },
        local.default_tags,
    )
}

resource "aws_route_table" "my_route_public" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-route_public"
        },
        local.default_tags,
    )
}

resource "aws_route_table" "my_route_private" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_ngw.id
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-route_private"
        },
        local.default_tags,
    )
}

resource "aws_route_table_association" "my_route_assoc_public" {
    route_table_id = aws_route_table.my_route_public.id
    subnet_id = aws_subnet.my_subnet_public.id
}

resource "aws_route_table_association" "my_route_assoc_private" {
    route_table_id = aws_route_table.my_route_private.id
    subnet_id = aws_subnet.my_subnet_private.id
}

resource "aws_vpc_endpoint" "my_s3_endpoint" {
    vpc_id = aws_vpc.my_vpc.id
    service_name = "com.amazonaws.${var.aws_region}.s3"
    route_table_ids = [
        aws_route_table.my_route_public.id,
        aws_route_table.my_route_private.id
    ]
}

resource "aws_network_acl" "my_nacl" {
    vpc_id = aws_vpc.my_vpc.id
    subnet_ids = [
        aws_subnet.my_subnet_public.id,
        aws_subnet.my_subnet_private.id
    ]
    ingress {   # Puedes agregar varios bloques de ingress si se desea más reglas
        rule_no = 100   # Se ejecutan de menor a mayor
        protocol = "-1" # -1 es todos los protocolos (tpc o udp) y si se usa -1 los puertos van de 0 a 0
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
        action = "allow"
    }
    egress {
        rule_no = 100
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
        action = "allow"
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-nacl"
        },
        local.default_tags,
    )
}

resource "aws_security_group" "my_sg_alb" {
    vpc_id = aws_vpc.my_vpc.id
    name = "${local.name_prefix}-sg-alb"
    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        security_groups = [
            aws_security_group.my_sg_ec2.id
        ]
    }
    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        security_groups = [
            aws_security_group.my_sg_ec2.id
        ]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-sg-alb"
        },
        local.default_tags,
    )
}

resource "aws_security_group" "my_sg_ec2" {
    vpc_id = aws_vpc.my_vpc.id
    name = "${local.name_prefix}-sg-ec2"
    ingress {
        protocol  = "tcp"
        from_port = 22
        to_port   = 22
        cidr_blocks = [
            aws_vpc.my_vpc.cidr_block
        ]
    }
    ingress {
        protocol  = "tcp"
        from_port = 80
        to_port   = 80
        cidr_blocks = [
            aws_vpc.my_vpc.cidr_block
        ]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-sg-ec2"
        },
        local.default_tags,
    )
}
resource "aws_security_group" "my_sg_rds" {
    vpc_id = aws_vpc.my_vpc.id
    name = "${local.name_prefix}-sg-rds"
    ingress {
        protocol  = "tcp"
        from_port = 3306
        to_port   = 3306
        cidr_blocks = [
            aws_vpc.my_vpc.cidr_block
        ]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-sg-rds"
        },
        local.default_tags,
    )
}

resource "aws_security_group" "my_sg_jumpbox" {
    vpc_id = aws_vpc.my_vpc.id
    name = "${local.name_prefix}-sg-jumpbox"
    ingress {
        protocol    = "tcp"
        from_port   = 3389
        to_port     = 3389
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    tags = merge(
        {
            "Name" = "${local.name_prefix}-sg-jumpbox"
        },
        local.default_tags,
    )
}