# ssh key pair from local mac
resource "aws_key_pair" "runner_key" {
  key_name   = "runner-key"
  public_key = file("${path.module}/runner-key.pub")
}

# ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] #amd64 arch + hvm support
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#security group
resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Allow SSH and outbound internet" 

  ingress {
    description = "Allow inbound SSH access from anywhere"           
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow inbound Grafana access from anywhere"           
    from_port   = 30300
    to_port     = 30300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow unrestricted outbound internet access"     
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ec2 runner
resource "aws_instance" "github_runner" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.runner_key.key_name # points to the resource above

  vpc_security_group_ids = [aws_security_group.runner_sg.id]

#override default to 20gb and gp3
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "GitHub-Actions-Runner"
  }
}

# runner ip
output "runner_ip" {
  value = aws_instance.github_runner.public_ip
}