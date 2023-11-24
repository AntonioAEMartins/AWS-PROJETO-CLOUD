# variable "user_data" {
#     description = "Initialization String for FastAPI"
#     type = string
#     default = "uvicorn sql_app.main:app"
# }

variable "user_data" {
    description = "Initialization String for FastAPI"
    type = string
    default = <<-EOF
        #!/bin/bash
        sudo apt-get update
        sudo apt-get install -y nginx
        sudo systemctl enable nginx
        sudo systemctl start nginx
    EOF
}