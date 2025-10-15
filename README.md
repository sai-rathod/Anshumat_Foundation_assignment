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
├── main.tf                    # Root module configuration
├── my-key                     # Private SSH key
├── my-key.pub                 # Public SSH key
└── iac/                       # IAC module directory
    ├── file.txt               # User data script for EC2
    └── my-IAC/                # Module files
        ├── variables.tf
        ├── main.tf
        ├── outputs.tf
        └── ...
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

### Step 2: Clone/Create Project Structure

Navigate to your project directory:

```bash
cd ~/terraform/aws-vpc/Anshumat_Foundation_assignment
```

### Step 3: Generate SSH Key Pair

Generate SSH key pair in the root directory (same level as `main.tf`):

```bash
ssh-keygen -t rsa -b 2048 -f my-key -N ""
```

This creates:
- `my-key` (private key)
- `my-key.pub` (public key)

**Important**: Keep your private key secure and never commit it to version control.

### Step 4: Create User Data File

Create the user data file inside the `iac` directory:

```bash
cd iac
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

cd ..
```

### Step 5: Verify Region Configuration

Ensure the region in your AWS CLI configuration matches the region in your Terraform configuration:

```bash
# Check AWS CLI region
aws configure get region

# Update if needed
aws configure set region ap-south-1
```

**Note**: The AMI ID (`ami-02d26659fd82cf299`) should be valid for your selected region.

### Step 6: Initialize Terraform

Initialize Terraform to download required providers and modules:

```bash
terraform init
```

### Step 7: Validate Configuration

Validate your Terraform configuration:

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 8: Plan Infrastructure

Review the infrastructure changes before applying:

```bash
terraform plan
```

### Step 9: Apply Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## 📊 Module Configuration

### Input Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
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

- `public_instance_ip`: Public IP address of the EC2 instance
- `vpc_id`: VPC ID
- `dynamodb_table`: DynamoDB table name

## 🔐 Connecting to EC2 Instance

After deployment, connect to your instance:

```bash
# Set proper permissions for private key
chmod 400 my-key

# SSH into the instance
ssh -i my-key ubuntu@<public_instance_ip>
```

Replace `<public_instance_ip>` with the actual IP from Terraform output.

## 🧹 Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

## 📝 Important Notes

1. **AMI ID**: Ensure the AMI ID is valid for your selected region. Update if necessary.
2. **Region Consistency**: AWS CLI region must match Terraform configuration region.
3. **Security**: Never commit private keys (`my-key`) to version control. Add to `.gitignore`.
4. **Costs**: Be aware that running EC2 instances and other AWS resources incur costs.
5. **User Data**: Modify `iac/file.txt` according to your application requirements.

## 🔍 Troubleshooting

### Issue: "Invalid AMI ID"
- **Solution**: Update the AMI ID to a valid one for your region. Check AWS Console > EC2 > AMIs.

### Issue: "Authentication Failed"
- **Solution**: Verify AWS credentials with `aws sts get-caller-identity`.

### Issue: "Region Mismatch"
- **Solution**: Ensure AWS CLI and Terraform use the same region.

### Issue: "Module Not Found"
- **Solution**: Run `terraform init` to initialize modules.

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is for educational purposes as part of Anshumat Foundation Assignment.

---

**Created by**: Anshumat Foundation Assignment  
**Last Updated**: October 2025
