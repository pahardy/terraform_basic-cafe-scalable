#Report the DNS name of the LB for client access
output "lb_dns_name" {
  value = aws_lb.cafe-app-lb.dns_name
}