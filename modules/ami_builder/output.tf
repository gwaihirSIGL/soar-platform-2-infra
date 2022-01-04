output "built_ami_id" {
    value = aws_ami_from_instance.built_ami.id
}