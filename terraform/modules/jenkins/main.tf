{
    "variables" : {
        "region" : "eu-west-3",
        "source_ami" : "ami-0ebc281c20e89ba4b"
    },
    "builders" : [
        {
            "type" : "amazon-ebs",
            "profile" : "default",
            "region" : "{{user `region`}}",
            "instance_type" : "t2.micro",
            "source_ami" : "{{user `source_ami`}}",
            "ssh_username" : "ec2-user",
            "ami_name" : "jenkins-master-2.107.2",
            "ami_description" : "Amazon Linux Image with Jenkins Server",
            "run_tags" : {
                "Name" : "packer-builder-docker"
            },
            "tags" : {
                "Tool" : "Packer",
                "Author" : "mlabouardy"
            }
        }
    ],
    "provisioners" : [
        {
            "type" : "file",
            "source" : "COPY FILES",
            "destination" : "COPY FILES"
        },
        {
            "type" : "shell",
            "script" : "./setup.sh",
            "execute_command" : "sudo -E -S sh '{{ .Path }}'"
        }
    ]
}