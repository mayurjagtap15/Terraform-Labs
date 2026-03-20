#!/bin/bash

LOG_FILE="terraforminstall.log"

# Redirect all output (stdout + stderr) to log file
exec > >(tee -a ${LOG_FILE}) 2>&1

echo "===== Terraform Installation Started: $(date) ====="

# Exit immediately if a command exits with non-zero status
set -e

# Function to check last command status
check_error() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1 failed. Exiting..."
        exit 1
    fi
}

echo "Updating package manager and installing dependencies..."
sudo apt-get update -y
check_error "apt-get update"

sudo apt-get install -y gnupg software-properties-common curl unzip
check_error "Dependency installation"

echo "Adding HashiCorp GPG key..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
check_error "Adding HashiCorp GPG key"

echo "Adding HashiCorp repository..."
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
check_error "Adding repository"

echo "Installing Terraform via apt..."
sudo apt-get update -y
sudo apt-get install -y terraform
check_error "Terraform installation via apt"

echo "Downloading Terraform binary directly..."
wget https://releases.hashicorp.com/terraform/1.14.7/terraform_1.14.7_linux_amd64.zip
check_error "Terraform binary download"

echo "Unzipping Terraform binary..."
unzip -o terraform_1.14.7_linux_amd64.zip
check_error "Unzip Terraform binary"

echo "Moving Terraform binary to /usr/local/bin..."
sudo mv -f terraform /usr/local/bin/
check_error "Move Terraform binary"

echo "Verifying Terraform installation..."
terraform -v
check_error "Terraform verification"

echo "===== Terraform Installation Completed Successfully: $(date) ====="
exit 0
