Terraform Command Basics
Step-01: Introduction
Understand basic Terraform Commands
terraform init (Terraform init is used to download or send a request to a target cloud service provider e.g AWS, to validate the secret key and the access key)
terraform validate (This checks and validates the terraform syntax)
terraform plan (This is to show you the desired state of your infrastructure)
terraform apply
terraform destroy

Every AWS resource should have a tag. This is a best practice.


## To configure custom profile in AWS (Do this in your terminal/powershell/ubuntu terminal. NOT VsCode)

aws configure --profile name of your choice profile

## To check the available profiles
ls -al
cd .aws
ls
cat credentials

## Variable blocks
Variable block is used to declare and reference a value. For example
The main reason for using variable block is to avoid HARDCODING. Avoiding hardcoding simply means not allowing certain values to be declared in your MAIN BLOCK.

## Output Block
This enables to view information or get certain attributes in your resources without having to check the console or GUI. This is essential when you have no access to the GUI or the console.

## Data source Block


## To push codes to GitHub
In order to push your code to GitHub, you must be in the root of your project by using "cd .."

Now, use "chmod +x git-command.sh". This ensures the code has the neccessary access using the "chmod" command

The perform the command "bash git-command.sh" . This will execute all the commands in the file git-command.sh
