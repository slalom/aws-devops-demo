# Tags
tag_manager = "Jimmy Bell"
tag_market  = "NorCal"
tag_office  = "San Francisco"
tag_email   = "gus.price@slalom.com"

# Infra Vars
stack_name = "slalom-devops-demo"
environment = "poc"
region = "us-west-2"
profile = "slalom-innovation"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCg/n79KNrm5/NF7boCC9WhkvmiVjGbdH+Hi3AnU965FwaTlG68vtJyjqBAeq8kF4UuAyuq9J4O8KraqFjOeMymjan/cmbQ2jI+Zd2MeloG9YCuFnAg/OJNy8FWmDEKg672sk+vgA3R/PBxzK7TAM2gYRXWhYmaDUQNKVch7ft9XqqfQMaujv1lDpId6eQqR2n56MEB/MblnzA7Fcap+KrNvtzRV0+RFlOUByBT9ubmFw/6/CihaXE6n+SpmCMxItDifb02Jv1Yyg9tt2Hu/xZI010lkUjlPKDu+6BGur60fQ941lpPoIuUEdSmcgHUReN3Sb0/M9Lf3FBU9CCnTMD1"

build_nat_gateway = true

vpc_cidr = "172.32.0.0/24"
availability_zone_1 = "us-west-2a"
availability_zone_2 =   "us-west-2b"

subnet_public_cidr_1 = "172.32.0.0/26"
subnet_public_cidr_2 = "172.32.0.64/26"
subnet_private_cidr_1 = "172.32.0.128/26"
subnet_private_cidr_2 = "172.32.0.194/26"

#Bastion params
bastion_ami_id = "ami-0c5204531f799e0c6"
bastion_instance_type = "t2.micro"

#Jenkins
kms_bucket = "kms-bucket"