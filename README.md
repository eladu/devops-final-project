
This is my try to do the final project in devops course 
I manged to create the folders structure for both tasks but there is code only in the files of task 1 that is:
    modules ec2 and network folders and the files in them.
    dev.tfvars
    stage.tfvars
    prod.tfvars
    main.tf
    variables.tf
    outputs.tf


The code was created using Gemini. 
The code creates an enviurment in AWS that include:
  1 VPC
  1 Public subnet
  1 Private subnet
  1 Bastion EC2 instance
  and 4 EC2s for Prod env. 
All these are created only when runing the terraform plan for the prod workspace. 

Then we need to manually change workspaces and apply for each one of them to create:
3 EC2s for Stage env.
and 2 EC2s for Dev env. 

There is a problem with this code since it does not create the inbound role for the bastion to be open for SSH connections. 
The inbound role that is created allows to connect only from the VPC local subnet. 

Since i have no more time to deal with the project tasks I will add no more ...



    
