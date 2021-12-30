# Requirements

CLI needed:
```
aws-cli
terraform
ssh-keygen
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

# Usage

```
terraform plan
terraform apply
ssh -i soar-key ec2-user@<instance-ip>
```

# WIP
ssh not working yet
