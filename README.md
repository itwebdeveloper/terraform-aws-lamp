# AWS infrastructure for LAMP applications
## Description
Programmatically create the AWS infrastructure for a PHP LAMP (Laravel, Apache, MySQL, PHP) application using Terraform.

# Deploy a demo application
## Create the Terraform project folder
1. Use `examples/simple-app` as root folder for your new application and include `terraform-aws-lamp` inside the `modules` folder. E.g.:
    ```
    cp -r ~/code/terraform-aws-serverless-bref/examples/simple-app ~/code
    cd ~/code/simple-app
    mkdir modules
    cd modules
    cp -r ~/code/terraform-aws-serverless-bref .
    ```
2. Change directory to the `artifact` folder:
    ```
    cd ~/code/simple-app/artifact
    ```

## Clone the Git repository
1. Create a new or copy an existing Laravel application inside the `artifact` folder:
    ```
    composer create-project laravel/laravel example-app
    cd example-app
    ```
## Build the application
1. Install the Javascript dependecies:
    ```
    npm install
    npm build
    ```

1. Generate the app key:
    ```
    php artisan key:generate
    ```

1. Include the [Bref](https://bref.sh/docs/frameworks/laravel.html) packages:
    ```
    composer require bref/bref bref/laravel-bridge --update-with-dependencies
    ```

1. Install the PHP dependecies:
    ```
    composer install
    ```

1. Create a static configuration cache file:
    ```
    php artisan config:cache
    ```

## Build the artifact
1. Delete the existing archive (if it exists):
    ```
    rm ../simple-app.zip
    ```

1. Compress the application in an archive:
    ```
    zip -r ../simple-app.zip . -x 'node_modules/*' 'public/storage/*' 'resources/assets/*' 'storage/*' 'tests/*'
    ```
    > If you want to exclude additional directories or files, add their patch after the `-x` argument.

1. Create a checksum for the archive:
    ```
    cd ~/code/simple-app/artifact
    openssl dgst -sha256 -binary simple-app.zip | openssl enc -base64 > simple-app.zip.sha256
    ```

## Configure the Terraform module
1. Create the `terraform.tfvars` file:
    ```
    cd ~/code/simple-app/
    cp terraform.tfvars.example terraform.tfvars
    ```

1. Edit the `terraform.tfvars` file:
    ```
    vi terraform.tfvars
    ```

    > Please, make sure to use the [AWS Lambda layers](https://runtimes.bref.sh/) matching version of the `bref/bref` PHP package for the exact region you are provisioning the infrastructure to.

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