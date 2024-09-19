### how to handle sensitive data in terraform ####

Variables.tf ( create variables with sensitivity true )

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}


main.tf ( use those variables when creating resources)

resource "aws_db_instance" "database" {
  allocated_storage = 5
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name = aws_db_subnet_group.private.name

  skip_final_snapshot = true
}

If you were to run terraform apply now, Terraform would prompt 
you for values for these new variables since you haven't assigned defaults to them.
which is not ideal,

Thats why  2 diffrent methods can be used  to assign values to already declared variables
to keep them safe

1. Set values with a .tfvars file
2. Set values with env variables


#1. Set values with a .tfvars file

Terraform supports setting variable values with variable definition (.tfvars) files. 
You can use multiple variable definition files, and many practitioners use a separate 
file to set sensitive or secret values.

#>Create a new file called secret.tfvars to assign values to the new variables.
#>these variables are already created in variables.tf file

      # file name >  secrets.tfvars    
      db_username = "admin"
      db_password = "insecurepassword"

Apply these changes using the -var-file parameter. Respond to the confirmation prompt with yes.
      # command > $ terraform apply -var-file="secret.tfvars"

Setting values with a .tfvars file allows you to separate sensitive values from the rest of your 
variable values,and makes it clear to people working with your configuration which values are sensitive.
However, it requires that you maintain and share the secret.tfvars file with only the appropriate people. 
You must also be careful not to check .tfvars files with sensitive values into version control. 
For this reason, GitHub's recommended .gitignore file for Terraform configuration is configured to ignore 
files matching the pattern *.tfvars.    


#2. Set values with env variables

Set the database administrator username and password ( or any sensitive data you want to hide) 
using environment variables for Terraform Community Edition (diff method for terraform HCP Edition)
When Terraform runs, it looks in your environment for variables that match the pattern # > TF_VAR_<VARIABLE_NAME>, 
and assigns those values to the corresponding Terraform variables in your configuration.

# > export TF_VAR_db_username=admin TF_VAR_db_password=adifferentpassword

Now, run terraform apply, and Terraform will assign these values to your new variables.


## -------Reference sensitive variables------ ##

When you use sensitive variables in your Terraform configuration, you can use them as you would any other variable.
Terraform will redact these values in command output and log files, and raise an error when it detects that 
they will be exposed in other ways.

#Add the following output values to outputs.tf
output "db_connect_string" {
  description = "MySQL database connection string"
  value       = "Server=${aws_db_instance.database.address}; Database=ExampleDB; Uid=${var.db_username}; Pwd=${var.db_password}"
  sensitive   = true
}
Apply above change to see that Terraform will now redact the database connection string output.


##-------- Sensitive values in state ------- ## 

When you run Terraform commands with a local state file, Terraform stores the state as plain text,
including variable values, even if you have flagged them as sensitive.
Terraform needs to store these values in your state so that it can tell 
if you have changed them since the last time you applied your configuration.

# $ grep "password" terraform.tfstate
  "value": "Server=terraform-20210113192204255400000004.ct4cer62f3td.us-east-1.rds.amazonaws.com;
    Database=ExampleDB; Uid=admin; Pwd=adifferentpassword",
            "password": "adifferentpassword",

# Marking variables as sensitive is not sufficient to secure them. 
# You must also keep them secure while passing them into Terraform configuration, and protect them in your state file.
# you must keep your Terraform state file secure to avoid accidentally exposing sensitive data.

