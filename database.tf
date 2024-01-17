#Creating a database
resource "aws_db_instance" "backend-db" {
  allocated_storage = 10
  identifier_prefix = "backenddb"
  engine = "mysql"
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "backenddb"
  username = var.db_username
  password = var.db_password
}