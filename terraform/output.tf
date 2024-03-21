output "public_dns_hostname" {
  value = "http://${aws_lb.luwan_lb.dns_name}"
}

output "endpoint" {
  value = aws_eks_cluster.luwan_eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.luwan_eks.certificate_authority[0].data
}