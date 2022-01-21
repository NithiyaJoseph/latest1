provider "aws" {
  region = "us-east-1"
}

locals {
  serverconfig = [
    for srv in var.configuration : [
      for i in range(1, srv.no_of_instances+1) : {
        instance_name = "${srv.application_name}-${i}"
        instance_type = srv.instance_type
        ami = srv.ami
      }
    ]
  ]
}

locals {
  instances = flatten(local.serverconfig)
}

resource "aws_instance" "common" {

  for_each = {for server in local.instances: server.instance_name =>  server}
  
  ami           = each.value.ami
  instance_type = each.value.instance_type
    tags = {
    Name = "${each.value.instance_name}"
  }
}

output "instances" {
  value       = "${aws_instance.common}"
  description = "Instance Details"
}
