variable region {
  type        = string
  default     = "us-west-2"
}


variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  type        = list
  description = "List of availability zones"
}