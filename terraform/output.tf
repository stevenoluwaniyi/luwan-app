output "public_dns_hostname" {
  value = "http://${aws_lb.darasimi_lb.dns_name}"
}