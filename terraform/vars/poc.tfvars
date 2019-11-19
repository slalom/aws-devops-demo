# Tags
tag_manager = "Jimmy Bell"
tag_market  = "NorCal"
tag_office  = "San Francisco"
tag_email   = "gus.price@slalom.com"

# Infra Vars
stack_name = "slalom-devops-demo"
region = "us-west-1"
environment = "poc"
profile = "slalom-innovation"

vpc_cidr = "172.16.0.0/24"
availability_zones = [
  "us-west-1a",
  "us-west-1c"
]
subnet_public_cidrs = [
  "172.16.0.0/26",
  "172.16.0.64/26",
]
subnet_private_cidrs = [
  "172.16.0.128/26",
  "172.16.0.194/26",
]

#Bastion params
bastion_ami_id = "ami-024c80694b5b3e51a"
bastion_instance_type = "t2.micro"
bastion_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCg/n79KNrm5/NF7boCC9WhkvmiVjGbdH+Hi3AnU965FwaTlG68vtJyjqBAeq8kF4UuAyuq9J4O8KraqFjOeMymjan/cmbQ2jI+Zd2MeloG9YCuFnAg/OJNy8FWmDEKg672sk+vgA3R/PBxzK7TAM2gYRXWhYmaDUQNKVch7ft9XqqfQMaujv1lDpId6eQqR2n56MEB/MblnzA7Fcap+KrNvtzRV0+RFlOUByBT9ubmFw/6/CihaXE6n+SpmCMxItDifb02Jv1Yyg9tt2Hu/xZI010lkUjlPKDu+6BGur60fQ941lpPoIuUEdSmcgHUReN3Sb0/M9Lf3FBU9CCnTMD1 gus.price@slalom.com"
