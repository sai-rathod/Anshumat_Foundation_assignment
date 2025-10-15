# AWS Infrastructure as Code (IAC) - Terraform Module

This project sets up a complete AWS infrastructure including VPC, subnets, EC2 instances, security groups, and DynamoDB table using Terraform modules.

## 📋 Prerequisites

- AWS CLI installed and configured
- Terraform installed (v1.0+)
- SSH key pair for EC2 instance access
- Basic understanding of AWS services and Terraform

## 🏗️ Infrastructure Components

- **VPC**: Custom Virtual Private Cloud
- **Subnets**: Public and Private subnets
- **EC2 Instance**: Public instance with custom user data
- **Security Groups**: Ports 20, 80, 443, 3000, 8080
- **DynamoDB Table**: NoSQL database table
- **SSH Key Pair**: For secure instance access

## 📁 Project Structure

```
.
└── iac/
    ├── README.md              # This file
    ├── main.tf                # Root module configuration
    ├── terraform.tf           # Provider and backend configuration
    ├── file.txt               # User data script for EC2
    ├── my-key                 # Private SSH key
    ├── my-key.pub             # Public SSH key
    └── my-IAC/                # Module directory
        ├── module_file.tf     # Module main resources
        ├── variables.tf       # Module input variables
        └── output.tf          # Module outputs
```

## 🚀 Setup Instructions

### Step 1: Configure AWS CLI

```bash
aws configure
```

Provide the following details:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `ap-south-1`)
- Default output format (e.g., `json`)

### Step 2: Navigate to Project Directory

```bash
cd iac
```

All commands should be run from the `iac` directory.

### Step 3: Generate SSH Key Pair

Generate SSH key pair in the `iac` directory:

```bash
ssh-keygen -t rsa -b 2048 -f my-key -N ""
```

This creates:
- `my-key` (private key)
- `my-key.pub` (public key)

**Important**: Keep your private key secure and never commit it to version control.

### Step 4: Create User Data File

Create or verify the `file.txt` in the `iac` directory with the following content:

```bash
cat > file.txt << 'EOF'
#!/bin/bash
# Update system packages
sudo apt-get update -y

# Install basic utilities
sudo apt-get install -y curl wget git

# Install Docker (optional)
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh

# Install Node.js (optional)
# curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
# sudo apt-get install -y nodejs

# Create a sample application directory
mkdir -p /home/ubuntu/app

# Add any custom initialization scripts here
echo "Instance initialized successfully" > /home/ubuntu/app/init.log

# Set hostname
hostnamectl set-hostname dev-instance
EOF
```

### Step 5: Verify terraform.tf Configuration

Ensure your `terraform.tf` file has the correct region configured:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"  # Change this to match your AWS CLI region
}
```

**Important**: The region in `terraform.tf` must match your AWS CLI configuration.

### Step 6: Verify Region Configuration

Ensure the region in your AWS CLI configuration matches the region in `terraform.tf`:

```bash
# Check AWS CLI region
aws configure get region

# Update if needed
aws configure set region ap-south-1
```

**Note**: The AMI ID (`ami-02d26659fd82cf299`) in `main.tf` should be valid for your selected region.

### Step 7: Initialize Terraform

Initialize Terraform to download required providers and modules:

```bash
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 8: Validate Configuration

Validate your Terraform configuration:

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 9: Format Configuration (Optional)

Format your Terraform files:

```bash
terraform fmt -recursive
```

### Step 10: Plan Infrastructure

Review the infrastructure changes before applying:

```bash
terraform plan
```

This will show you all resources that will be created.

### Step 11: Apply Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm. The deployment process will take a few minutes.

## 📊 Module Configuration

### Sample main.tf (For Reference)

```hcl
module "my-dev-module" {
    source = "./my-IAC"
    env = "dev"
    vpc_cidr = "10.10.0.0/16"
    public_subnet_cidr = "10.10.1.0/24"
    private_subnet_cidr = "10.10.2.0/24"
    sg_ports = [20,443,3000,8080,80]
    ami = "ami-02d26659fd82cf299"
    dynamodb_details = {
        name = "temp-table"
        hash_key = "TempID"
        type = "S"
    }
}

output "public_instance_ip" {
    value = module.my-dev-module.public_instance_ip
}

output "vpc_id" {
    value = module.my-dev-module.vpc_id
}

output "dynamodb_table" {
    value = module.my-dev-module.dynamodb_table
}
```

### Input Variables Explanation

| Variable | Description | Value |
|----------|-------------|-------|
| `env` | Environment name | `dev` |
| `vpc_cidr` | VPC CIDR block | `10.10.0.0/16` |
| `public_subnet_cidr` | Public subnet CIDR | `10.10.1.0/24` |
| `private_subnet_cidr` | Private subnet CIDR | `10.10.2.0/24` |
| `sg_ports` | Security group ports | `[20, 443, 3000, 8080, 80]` |
| `ami` | EC2 AMI ID | `ami-02d26659fd82cf299` |
| `dynamodb_details` | DynamoDB configuration | See below |

### DynamoDB Configuration

```hcl
dynamodb_details = {
    name = "temp-table"
    hash_key = "TempID"
    type = "S"
}
```

### Output Values

After successful deployment, Terraform will output:

```
Outputs:

dynamodb_table = "temp-table"
public_instance_ip = "xx.xx.xx.xx"
vpc_id = "vpc-xxxxxxxxx"
```

## 🔐 Connecting to EC2 Instance

After deployment, connect to your instance:

```bash
# Set proper permissions for private key
chmod 400 my-key

# SSH into the instance (replace with your actual IP from output)
ssh -i my-key ubuntu@<public_instance_ip>
```

Example:
```bash
ssh -i my-key ubuntu@13.232.45.67
```

## 📝 Viewing Infrastructure State

To view the current state:

```bash
# List all resources
terraform state list

# Show specific resource details
terraform state show module.my-dev-module.aws_instance.public_instance

# View outputs
terraform output
```

## 🔄 Updating Infrastructure

To update the infrastructure after making changes to configuration files:

```bash
terraform plan    # Review changes
terraform apply   # Apply changes
```

## 🧹 Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm. This will remove:
- EC2 instance
- VPC and subnets
- Security groups
- DynamoDB table
- All associated resources

## 📝 Important Notes

1. **Working Directory**: All Terraform commands must be run from the `iac` directory.
2. **AMI ID**: Ensure the AMI ID is valid for your selected region. Update in `main.tf` if necessary.
3. **Region Consistency**: AWS CLI region must match the region in `terraform.tf`.
4. **Security**: Never commit private keys (`my-key`) or state files to version control. Add to `.gitignore`:
   ```
   my-key
   *.tfstate
   *.tfstate.backup
   .terraform/
   ```
5. **Costs**: Be aware that running EC2 instances and other AWS resources incur costs.
6. **User Data**: Modify `file.txt` according to your application requirements.
7. **State Files**: `terraform.tfstate` and `terraform.tfstate.backup` are automatically generated and should not be manually edited.

## 🔍 Troubleshooting

### Issue: "Invalid AMI ID"
**Solution**: Update the AMI ID in `main.tf` to a valid one for your region.
```bash
# Find Ubuntu AMIs for your region
aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' --output table
```

### Issue: "Authentication Failed"
**Solution**: Verify AWS credentials.
```bash
aws sts get-caller-identity
```

### Issue: "Region Mismatch"
**Solution**: Check and align regions.
```bash
# Check AWS CLI region
aws configure get region

# Check terraform.tf for provider region
grep -A 2 'provider "aws"' terraform.tf
```

### Issue: "Module Not Found"
**Solution**: Run `terraform init` from the `iac` directory.

### Issue: "Error locking state"
**Solution**: If previous apply was interrupted:
```bash
terraform force-unlock <LOCK_ID>
```

### Issue: "Permission Denied (publickey)"
**Solution**: Check SSH key permissions and path.
```bash
chmod 400 my-key
ssh -i my-key -v ubuntu@<ip>  # Verbose mode for debugging
```

## 📚 Module Structure

### my-IAC Module

The `my-IAC` module contains:

- **module_file.tf**: Main resource definitions (VPC, subnets, EC2, security groups, DynamoDB)
- **variables.tf**: Input variable declarations
- **output.tf**: Output value definitions

This modular approach allows for:
- Code reusability
- Easy environment management (dev, staging, prod)
- Cleaner configuration
- Better organization

## 🎯 Common Tasks

### View All Resources
```bash
terraform state list
```

### Get Outputs
```bash
terraform output
terraform output public_instance_ip
```

### Refresh State
```bash
terraform refresh
```

### Check Configuration
```bash
terraform validate
terraform fmt -check
```

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform Modules](https://www.terraform.io/docs/language/modules/index.html)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is for educational purposes as part of Anshumat Foundation Assignment.

---

**Project**: Anshumat Foundation Assignment  
**Infrastructure**: AWS VPC with EC2 and DynamoDB  
**Tool**: Terraform  
**Last Updated**: October 2025
