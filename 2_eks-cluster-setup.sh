#!/bin/bash

# Use existing AWS credentials setup as part of 1_cli_installs script
export AWS_PROFILE=user2
echo -e "\naws credentials being used are: $(aws sts get-caller-identity)\n"

# Create an EKS cluster without node groups (node groups will be created subsequently)
echo -e "\n Creating eks cluster\n"
eksctl create cluster --name veks --region us-east-1 --zones us-east-1a,us-east-1b --without-nodegroup

# Create and associate OIDC provider with eks cluster created above
echo -e "\nCreate and associate IAM OIDC Provider\n"
eksctl utils associate-iam-oidc-provider --cluster veks --region us-east-1 --approve

# Create an ssh keypair and import it into AWS to be used as ssh keypair to login to EKS nodes
echo -e "\nCreate and import ssh keypair\n"
ssh-keygen -t rsa -C "v-key" -f ~/.ssh/v-key -q -N ""
aws ec2 import-key-pair --region us-east-1 --key-name v-key --public-key-material fileb://$HOME/.ssh/v-key.pub

# Create node group with additional permissions in public subnets
echo -e "\ncreating eks nodegroup\n"
eksctl create nodegroup --name v-eks-ng-public1 --cluster veks --region us-east-1 \
	--node-type t3.medium --nodes 2 --nodes-min 2 --nodes-max 4 --node-volume-size 20 --ssh-access \
	--ssh-public-key v-key --managed --asg-access --external-dns-access \
	--full-ecr-access --appmesh-access --alb-ingress-access

# List details about the cluster and nodes 
echo -e "\neks cluster info:\n $(eksctl get cluster)\n"
echo -e "\nnodegroup info:\n $(eksctl get nodegroup --cluster veks)\n"
echo -e "\nnodes in the cluster:\n $(kubectl get nodes -o wide)\n"
echo -e "\nkubectl context info:\n $(kubectl config view --minify)\n"


