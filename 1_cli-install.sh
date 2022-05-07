#!/bin/bash

# download and install aws cli v2
echo "Installing aws cli V2"
mkdir awscli
cd awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "###################################"
echo "aws cli version: $(aws --version)"
echo "###################################"

AWS_ACCESS_KEY_ID=$1
AWS_SECRET_ACCESS_KEY=$2
AWS_REGION=$3

if [ $# -ne 3 ]; then
	echo "Invalid arugments,please enter AWS_ACCWSS_KEY AWS_SECRET_ACCESS_KEY AWS_REGION"
	exit 1
fi 

echo "setting aws configuration"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile user2 && aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile user2 && aws configure set region "$AWS_REGION" --profile user2 && aws configure set output "text" --profile user2
export AWS_PROFILE=user2
echo "###################################"
echo "caller identity: $(aws sts get-caller-identity)"
echo "###################################"

echo "Installing kubectl"
cd ..
mkdir kubectlcli
cd kubectlcli
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#Temporarily setting kubectl version to 1.23.6 as I had issues with 1.24
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Provide execute permissions
chmod +x ./kubectl

# Set the Path by copying to user Home Directory
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile

# Verify the kubectl version
echo "###################################"
echo "kubectl version: $(kubectl version --short --client)"
echo -e "###################################\n"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "You must use a kubectl version that is within one minor version difference of your Amazon EKS cluster control plane. For example, a 1.21 kubectl client works with Kubernetes 1.20, 1.21 and 1.22 clusters"
echo -e "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
echo "Installing eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
echo "###################################"
echo "eksctl version: $(eksctl version)"
echo "###################################"
