module "iam_role_for_ec2_to_cloud_watch" {
  source              = "github.com/kenych/terraform_module_iam_role.git"
  assume_role_policy  = "${file("policies/aws_iam_assume_role_ec2.json")}"
  aws_iam_role_policy = "${file("policies/aws_iam_role_policy_cloud_watch.json")}"
  role_purpose        = "${var.role_purpose}"
}

resource "aws_instance" "centos" {
  ami           = "ami-dff017b8"
  instance_type = "t2.micro"

  key_name = "terraform_ec2_key"

  tags {
    Name = "helloTerraformCloudWatch"
  }

  iam_instance_profile = "iam_instance_profile_m_${var.role_purpose}"

  key_name = "terra"

//  user_data = "${file("init.sh")}"
  user_data = "${data.template_file.cloud_watch_custom_metric.rendered}"

  provisioner "local-exec" {
    command = "echo Public IP:     ${self.public_ip}"
  }
}
