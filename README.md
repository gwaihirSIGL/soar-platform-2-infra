# Requirements

CLI needed:
```
aws-cli
terraform
ssh
```
Generate a PAT with the following rights:
- Full control of private repositories


# Installation

```
# setup aws credentials
aws configure

# install terraform modules
terraform init

# create ssh key to connect to instances
ssh-keygen -t rsa -b 4096 -f soar-key
```

# Configuration

Set the following environment variables for terraform:
- TF_VAR_gittoken
- TF_VAR_gittoken
- TF_VAR_database_password

# Usage

```
terraform plan
terraform apply
ssh -i soar-key ec2-user@<instance-ip>
```

# WIP
connect database to back
conect back to front
