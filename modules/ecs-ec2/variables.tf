variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}

variable "subnet_ids" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
