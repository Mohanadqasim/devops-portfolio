# Fetch the Hosted Zone automatically created by Route 53 registration
data "aws_route53_zone" "primary" {
  name         = "mohanad-portfolio.click"
  private_zone = false
}

# Apex A Record (mohanad-portfolio.click -> EC2 Elastic IP)
resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "mohanad-portfolio.click"
  type    = "A"
  ttl     = 300
  records = [aws_eip.portfolio_eip.public_ip]
}

# WWW Subdomain Record (www.mohanad-portfolio.click -> EC2 Elastic IP)
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.mohanad-portfolio.click"
  type    = "A"
  ttl     = 300
  records = [aws_eip.portfolio_eip.public_ip]
}