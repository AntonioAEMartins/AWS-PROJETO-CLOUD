variable "target_group_timeout" {
    description = "Timeout for the target group"
    type        = number
    default     = 5
}

variable "target_group_health_threshold" {
    description = "Health threshold for the target group"
    type        = number
    default     = 5
}

variable "target_group_unhealthy_threshold" {
    description = "Unhealthy threshold for the target group"
    type        = number
    default     = 2
}

variable "target_group_instance_type" {
    description = "Instance type for the target group"
    type        = string
    default     = "instance"
}

variable "lb_target_group_name" {
  description = "Name for the target group"
  type        = string
  default     = "cloud-target-group"
}

variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
  default     = "cloud-application-lb"
}

variable "lb_tags" {
  description = "Tags for the load balancer"
  type        = map(string)
  default     = {
    name = "cloud_application_lb"
  }
}

variable "lb_listener_port" {
  description = "Port for the load balancer listener"
  type        = number
  default     = 80
}