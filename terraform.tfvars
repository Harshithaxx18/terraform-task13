region      = "eu-west-1"
name_prefix = "cmtr-cbzir072"
vpc_name    = "cmtr-cbzir072-vpc"

public_subnet_names = [
  "cmtr-cbzir072-public-subnet1",
  "cmtr-cbzir072-public-subnet2"
]

ssh_sg_name  = "cmtr-cbzir072-sg-ssh"
http_sg_name = "cmtr-cbzir072-sg-http"
lb_sg_name   = "cmtr-cbzir072-sg-lb"

instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1

blue_weight  = 100
green_weight = 0

tags = {
  Project   = "cmtr-cbzir072"
  ManagedBy = "Terraform"
}