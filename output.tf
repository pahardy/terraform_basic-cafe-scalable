#Report the DNS name of the LB for client access
output "lb_dns_name" {
  value = aws_lb.cafe-app-lb.dns_name
}

#Report the DB address and port
output "db_address" {
  value= aws_db_instance.backend-db.address
}

#Report the port used by the DB
output "db_port" {
  value= aws_db_instance.backend-db.port
}