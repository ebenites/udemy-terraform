data "aws_iam_policy_document" "my_policy_assume" {
    statement {
        actions = [
            "sts:AssumeRole",
        ]
        principals {
            type = "Service"
            identifiers = [
                "ec2.amazonaws.com"
            ]
        }
        effect = "Allow"
    }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "my_role" {
    name = "${local.name_prefix}-role"
    assume_role_policy = data.aws_iam_policy_document.my_policy_assume.json    # Puedes usar el bloque <<EOF { ... } EOF   (Para que pueda ser asignado a un EC2)
}

data "aws_iam_policy" "my_policy_s3fullaccess" {
    arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_iam_role_policy_attachment" "my_role_policy_attachment" {
    role = aws_iam_role.my_role.name
    policy_arn = data.aws_iam_policy.my_policy_s3fullaccess.arn  # Puedes colocar directamente el string arn de AmazonS3FullAccess
}

resource "aws_iam_instance_profile" "my_instance_profile" {
    name =  "${local.name_prefix}-instance-profile"
    role = aws_iam_role.my_role.name
}


# En IBK ver como otro ejemplo iam-task-fargate.tf
