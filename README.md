# AWS infrastructure for LAMP applications
## Description
Programmatically create the AWS infrastructure for a PHP LAMP (Laravel, Apache, MySQL, PHP) application using Terraform.

# Deploy a demo application
## Create the Terraform project folder
1. Use `examples/simple-app` as root folder for your new application and include `terraform-aws-lamp` inside the `modules` folder. E.g.:
    ```
    cp -r ~/code/terraform-aws-lamp/examples/simple-app ~/code
    cd ~/code/simple-app
    mkdir modules
    cd modules
    cp -r ~/code/terraform-aws-lamp .
    ```

## Provision the infrastrure and deploy the application
1. Initate Terraform:
    ```
    terraform init
    ```

1. Preview the infrastructure:
    ```
    terraform plan
    ```

1. Create the infrastructure:
    ```
    terraform apply
    # Review and respond with "yes"
    ```