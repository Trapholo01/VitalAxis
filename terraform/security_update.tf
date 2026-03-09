# SSH access restricted to my IP
resource "aws_security_group_rule" "ssh_my_ip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["102.212.63.248/32"]
  security_group_id = aws_security_group.ec2.id
  description       = "SSH from my IP only"
}
