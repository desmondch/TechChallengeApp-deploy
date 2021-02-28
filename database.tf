
resource "aws_db_instance" "tech_challenge_app_database" {
    allocated_storage = 10
    engine = "postgres"
    engine_version = "12"
    instance_class = "db.t3.micro"
    name = var.postgres_database_name
    username = var.postgres_username
    password = var.postgres_password
}
