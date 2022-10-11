resource "aws_instance" "u_web_server" {
  ami                    = "ami-0368e9f34d2618ed7"  # Ubuntu Server 18.04 LTS (HVM)
  instance_type          = "t3.micro"
  key_name               = "todo_key"
  iam_instance_profile   = aws_iam_instance_profile.ToDo_instance_profile.name
  vpc_security_group_ids = [aws_security_group.EC2_SecurityGroup.id]
  subnet_id              = aws_subnet.public_subnet.0.id
  monitoring             = true 

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "ToDo_App"
  }
}