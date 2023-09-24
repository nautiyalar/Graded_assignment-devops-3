variable "vpc_id" {
    default = "vpc-0a29bcc23978eda9d"
}

variable "subnet1" {
    default = "subnet-0659c2f344309404f"
}
variable "subnet2" {
    default = "subnet-099b097e0e5ca2088"
}


variable "instance_type" {
  description = "The EC2 instance type for the ASG instances."
  default     = "t2.micro"  # Change this to your desired instance type
}

variable "key_name" {
  description = "The name of the AWS Key Pair for SSH access to instances."
  default     = "test_access_key" # Change this to your key pair name
}