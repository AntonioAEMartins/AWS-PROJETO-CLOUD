variable "user_data" {
    description = "Initialization String for FastAPI"
    type = string
    default = "uvicorn sql_app.main:app"
}