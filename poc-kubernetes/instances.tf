

variable aws_access_key {}
variable aws_secret_key {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags {
    Name = "main"
  }
}

resource "aws_route_table_association" "route_assoc" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}


resource "aws_route53_zone" "dns_internal" {
  name = "ibrou.com"
  vpc_id = "${aws_vpc.main.id}"
  force_destroy = true
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
}

  tags {
    Name = "allow_all"
  }
}

resource "aws_instance" "master" {
    ami = "ami-ae7bfdb8"
    instance_type = "t1.micro"
    tags {
        Name = "master"
    }
    key_name = "kube"
    subnet_id = "${aws_subnet.main.id}"
    security_groups = [ "${aws_security_group.allow_all.id}" ]
    associate_public_ip_address = true
    root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
}


resource "aws_instance" "minion1" {
    ami = "ami-ae7bfdb8"
    instance_type = "t1.micro"
    tags {
        Name = "minion1"
    }
    key_name = "kube"
    subnet_id = "${aws_subnet.main.id}"
    security_groups = [ "${aws_security_group.allow_all.id}" ]
    associate_public_ip_address = true
    root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
}



resource "aws_instance" "minion2" {
    ami = "ami-ae7bfdb8"
    instance_type = "t1.micro"
    tags {
        Name = "minion2"
    }
    key_name = "kube"
    subnet_id = "${aws_subnet.main.id}"
    security_groups = [ "${aws_security_group.allow_all.id}" ]
    associate_public_ip_address = true
    root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
}


resource "aws_instance" "minion3" {
    ami = "ami-ae7bfdb8"
    instance_type = "t1.micro"
    tags {
        Name = "minion3"
    }
    key_name = "kube"
    subnet_id = "${aws_subnet.main.id}"
    security_groups = [ "${aws_security_group.allow_all.id}" ]
    associate_public_ip_address = true
    root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
}



resource "aws_route53_record" "master_dns" {
  zone_id = "${aws_route53_zone.dns_internal.zone_id}"
  name    = "master"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.master.private_ip}"]
}

resource "aws_route53_record" "minion1_dns" {
  zone_id = "${aws_route53_zone.dns_internal.zone_id}"
  name    = "minion1"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.minion1.private_ip}"]
}

resource "aws_route53_record" "minion2_dns" {
  zone_id = "${aws_route53_zone.dns_internal.zone_id}"
  name    = "minion2"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.minion2.private_ip}"]
}


resource "aws_route53_record" "minion3_dns" {
  zone_id = "${aws_route53_zone.dns_internal.zone_id}"
  name    = "minion3"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.minion3.private_ip}"]
}
