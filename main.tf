// Collecting Availability Zone in list
data "aws_availability_zones" "available" {}

// Create VPC
resource "aws_vpc" "mediawikivpc" {
    cidr_block = "${var.cidrblock}"
    enable_dns_hostnames = "true"
}

// Create IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.mediawikivpc.id}"
}

// Create EIP
resource "aws_eip" "nat" {
  vpc      = true
}


// Create Subnets
resource "aws_subnet" "subnet1" {
    cidr_block = "${var.subnet1_address_space}"
    vpc_id = "${aws_vpc.mediawikivpc.id}"
    map_public_ip_on_launch = "true"
    availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "subnet2" {
    cidr_block = "${var.subnet2_address_space}"
    vpc_id = "${aws_vpc.mediawikivpc.id}"
    map_public_ip_on_launch = "true"
    availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_subnet" "subnet3" {
    cidr_block = "${var.subnet3_address_space}"
    vpc_id = "${aws_vpc.mediawikivpc.id}"
    map_public_ip_on_launch = "true"
    availability_zone = "${data.aws_availability_zones.available.names[2]}"
}

// Create NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.subnet1.id}"
}

// Create Routing Table
resource "aws_route_table" "rtb" {
    vpc_id = "${aws_vpc.mediawikivpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
    tags = {
      Name = "Public-RT"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.mediawikivpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.gw.id}"
    }
    tags = {
      Name = "Private-RT"
    }
}

// Subnet Association
resource "aws_route_table_association" "rta_subnet1" {
    subnet_id = "${aws_subnet.subnet1.id}"
    route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta_subnet2" {
    subnet_id = "${aws_subnet.subnet2.id}"
    route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta_subnet3" {
    subnet_id = "${aws_subnet.subnet3.id}"
//    route_table_id = "${aws_vpc.mediawikivpc.default_route_table_id}"
//    route_table_id = "${aws_route_table.rtb.id}"
    route_table_id = "${aws_route_table.private.id}"
}


// Create Security Group
resource "aws_security_group" "elb-sg" {
    name = "elb_sg"
    vpc_id = "${aws_vpc.mediawikivpc.id}"

    # Allow HTTP from anywhere
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all oubound traffic
    egress {
        from_port = 0 
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
	Name = "ELB-sg"
    }
}

resource "aws_security_group" "mediawiki-sg" {
    name = "mediawiki_sg"
    vpc_id = "${aws_vpc.mediawikivpc.id}"

    # SSH from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
   tags = {
     Name = "MediaWiki-SG"
   }
}

resource "aws_security_group" "mariadb-sg" {
    name = "mariadb_sg"
    vpc_id = "${aws_vpc.mediawikivpc.id}"

    # SSH from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.10.8.0/22"]
    }

    # DB access from anywhere
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["10.10.8.0/22"]
    }

    # Outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "MariaDB-SG"
    }
}

// Create Classic Load Balancer
resource "aws_elb" "web" {
    name = "mediawiki-elb"

    subnets = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
    security_groups = ["${aws_security_group.elb-sg.id}"]
    instances = ["${aws_instance.mediawikiec2_1.id}", "${aws_instance.mediawikiec2_2.id}" ]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
}


// Create MediaWiki EC2 Instances
resource "aws_instance" "mediawikiec2_1" {
//    count = "2"
    ami = "ami-4bf3d731"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet1.id}"
    vpc_security_group_ids = ["${aws_security_group.mediawiki-sg.id}"]
    key_name = "${var.key_name}"

    connection {
        user = "centos"
        private_key = "${file("${var.private_key}")}"
    }
    provisioner "file" {
    source      = "files/ansible.sh"
    destination = "/tmp/ansible.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/ansible.sh",
        "/tmp/ansible.sh args",
      ]
    }

    provisioner "file" {
    source      = "files/httpd.conf"
    destination = "/tmp/httpd.conf"
    }

    provisioner "file" {
    source      = "files/mediawiki.yml"
    destination = "/tmp/mediawiki.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "ansible-playbook -i localhost /tmp/mediawiki.yml",
      ]
    }
   tags = {
     Name = "MediaWiki-1"
   }
}


resource "aws_instance" "mediawikiec2_2" {
    ami = "ami-4bf3d731"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet2.id}"
    vpc_security_group_ids = ["${aws_security_group.mediawiki-sg.id}"]
    key_name = "${var.key_name}"

    connection {
        user = "centos"
        private_key = "${file("${var.private_key}")}"
    }
    provisioner "file" {
    source      = "files/ansible.sh"
    destination = "/tmp/ansible.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/ansible.sh",
        "/tmp/ansible.sh args",
      ]
    }

    provisioner "file" {
    source      = "files/httpd.conf"
    destination = "/tmp/httpd.conf"
    }

    provisioner "file" {
    source      = "files/mediawiki.yml"
    destination = "/tmp/mediawiki.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "ansible-playbook -i localhost /tmp/mediawiki.yml",
      ]
    }
   tags = {
     Name = "MediaWiki-2"
   }
}

// Create Mariadb Instance
resource "aws_instance" "mediawiki_db" {
    ami = "ami-4bf3d731"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.subnet3.id}"
    vpc_security_group_ids = ["${aws_security_group.mariadb-sg.id}"]
    key_name = "${var.key_name}"
    user_data = "${file("files/install_mariadb.sh")}"
   
   tags = {
     Name = "MariaDB"
   }
}
