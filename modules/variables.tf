# variable "user_data" {
#     description = "Initialization String for FastAPI"
#     type = string
#     default = "uvicorn sql_app.main:app"
# }

variable "user_data" {
  description = "Initialization String for FastAPI"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    sudo apt-get update
    git clone https://github.com/AntonioAEMartins/simple_python_crud.git
  EOF
}