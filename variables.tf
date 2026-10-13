variable "region" {
  description = "AWS region where resources are created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used to build all resource names."
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the existing VPC."
  type        = string
}

variable "public_subnet_names" {
  description = "Name tags of the existing public subnets."
  type        = list(string)
}

variable "ssh_sg_name" {
  description = "Name of the existing SSH security group."
  type        = string
}

variable "http_sg_name" {
  description = "Name of the existing HTTP security group for EC2 instances."
  type        = string
}

variable "lb_sg_name" {
  description = "Name of the existing security group for the load balancer."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Blue and Green environments."
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in each Auto Scaling group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in each Auto Scaling group."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in each Auto Scaling group."
  type        = number
}

variable "blue_weight" {
  description = "Traffic weight for the Blue target group."
  type        = number
}

variable "green_weight" {
  description = "Traffic weight for the Green target group."
  type        = number
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
}