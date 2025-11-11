
This is my attempt to complete the final project in the DevOps course.

I managed to create the folder structure for both tasks, but there is code only in the files of task 1:

    modules, ec2, and network folders and the files in them.

    dev.tfvars
    
    stage.tfvars
    
    prod.tfvars
    
    main.tf
    
    variables.tf
    
    outputs.tf


The code was created using Gemini.

The code creates an environment in AWS that includes:

  1 VPC
  
  1 Public subnet
  
  1 Private subnet
  
  1 Bastion EC2 instance
  
  and 4 EC2s for Prod env.
  
All these are created only when running the Terraform plan for the prod workspace. 

Then we need to manually change workspaces and apply for each one of them to create:

3 EC2s for Stage env.

and 2 EC2s for Dev env. 


There is a problem with this code since it does not create the inbound role for the bastion to be open for SSH connections. 

The inbound role that is created allows connection only from the VPC local subnet. 

Since i have no more time to deal with the project tasks, I will add no more ...
