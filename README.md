# Requirements

```
aws-cli
terraform
```

# Installation

```
# setup aws credentials
aws configure

# install terraform modules
terraform init

# create ssh key to connect to instances
ssh-keygen -f soar-key
```

# Usage

```
terraform plan
terraform apply
ssh -i soar-key ec2-user@<instance-ip>
```

# WIP
ssh not working yet
