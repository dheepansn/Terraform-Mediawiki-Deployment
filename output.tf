output "elb_web" {
  value = [ "${aws_elb.web.dns_name}" ]
}

output "Use this IP to login to MediaWiki_Instance_1" {
  value = ["${aws_instance.mediawikiec2_1.public_ip}"]
}

output "Use this IP to login to MediaWiki_Instance_2" {
  value = ["${aws_instance.mediawikiec2_2.public_ip}"]
}

output "You can't directly connect to DB Instance, Use any of Webserver and connect to MediaWiki_Instance_DB with Private IP" {
  value = ["${aws_instance.mediawiki_db.private_ip}"]
}
