# Auto_Scaling_And_ELB_WITH_TF# Terraform AWS ELB and AutoScaling Group

This repository contains Terraform code to automate the creation of an Elastic Load Balancer (ELB) and AutoScaling Group in AWS. This setup ensures high availability and scalability for your applications by distributing incoming traffic across multiple instances and automatically adjusting the number of instances based on demand.

## Features

- **Elastic Load Balancer (ELB)**: Distributes incoming traffic across multiple EC2 instances for high availability.
- **AutoScaling Group**: Automatically adjusts the number of EC2 instances based on specified conditions to handle varying levels of traffic.
- **Configuration Flexibility**: Easily customize the number of instances, instance type, and other parameters.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS account with appropriate permissions to create and manage resources.
- AWS CLI configured with your credentials.

## Usage

1. **Clone the repository:**
   ```sh
   git clone [https://github.com/your-username/link_to_project](https://github.com/celetrialprince166/Auto_Scaling_And_ELB_WITH_TF.git)
   cd terraform-aws-elb-autoscaling
Initialize the Terraform working directory:

sh

 
terraform init
Customize the variables: Update the variables.tf file with your desired values, such as the instance type, AMI ID, and other parameters.

Plan the deployment:

sh

 ""
terraform plan
Apply the configuration:

sh

 ""
terraform apply
Confirm the apply with yes.

Variables
instance_type (default: t2.micro): The type of EC2 instance to use.

ami_id (default: ami-0c55b159cbfafe1f0): The AMI ID for the instances.

desired_capacity (default: 2): The desired number of instances in the AutoScaling Group.

min_size (default: 1): The minimum number of instances.

max_size (default: 4): The maximum number of instances.

Outputs
elb_dns_name: The DNS name of the created ELB.

autoscaling_group_id: The ID of the created AutoScaling Group.

License
This project is licensed under the MIT License. See the LICENSE file for details.

Contributing
Feel free to submit issues or pull requests if you have suggestions or improvements.

Acknowledgements
Special thanks to the Terraform community and AWS for their excellent tools and documentation.

Contact
For any questions or feedback, please reach out to princeayiku5@gmail.com.

