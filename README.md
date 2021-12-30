# Overview
This project allows you to build a custom image which can be deployed rapidly when you want to perform your training and allows for reproducible deployments in minutes rather than going through the entire build process each time. Its IaC performed by packer for building the custom image and terraform for the deployment of the image. It cost about $0.50-$0.70 per month to store the custom image and the deployment of the box is currently a preemptible box, however that could be changed. 

# Prerequsites
1. GCP billing account name found at https://console.cloud.google.com/billing, in the examples this is `My Billing Account FY22`.
2. Desired project ID name, in the examples this is `cvah-helk-training-fy22`.
3. Either a local Linux/MacOS machine or the Google Cloud Console where you can install the Google Cloud SDK and Terraform/Packer.

# Install Dependencies
## GCloud 
Follow instructions here: https://cloud.google.com/sdk/docs/install
For ubuntu/debian based you can copy and paste the following:
```bash
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
gcloud init
# This will allow the IaC that you run to utilize the creds/tokens provided by gcloud to auth to your services
gcloud auth application-default login 
```

### Google Cloud Console
You can also install get the GCloud SDK by default in your Google Cloud Console instance. The only gotcha is that once you've created your new project, you configure your project with a command like this (assuming the name of the project is `cvah-helk-training-fy22`)
```bash
gcloud config set project cvah-helk-training-fy22
```

## Install HashiCorp IaC products
Follow instructions here: https://learn.hashicorp.com/tutorials/packer/get-started-install-cli and here: https://learn.hashicorp.com/tutorials/terraform/install-cli
For ubuntu/debian based machines you can copy and paste the following 
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer terraform
```

# Clone the repo
```bash
git clone git@github.com:michael-smythe/cvah-train.git
```

# Quick Start
This will spin up a new project in your account via terraform, create the custom image via packer, and then deploy an instance of that image with terraform again. It relies on you having already authenticated via the gcloud tool. 
Take a look at the `quickstart.sh` file and see how to specify the billing account with a Terraform variable in the command `-var "gcp_billing_account_name=My Billing Account FY22"`
```bash
chmod +x ./quickstart.sh
./quickstart.sh
```

# New Project
This spins up a new project under your google account links it to your billing account and enables the appropriate APIs so that you can later build and deploy images and instances.
Specify your billing account with the Terraform variable in the command `-var "gcp_billing_account_name=My Billing Account FY22"`
```bash
cd ./terraform/setup
terraform init
terrafrom apply -auto-approve -var 'project_id=<PICK_A_NAME_FOR_THE_PROJECT_ID>'

# Example specifying a billing account:
# terraform init -var "gcp_billing_account_name=My Billing Account FY22" -var 'project_id=cvah-helk-training-fy22'
# terraform apply -var "gcp_billing_account_name=My Billing Account FY22" -var 'project_id=cvah-helk-training-fy22'
```

If you're using your Google Cloud Console instance, configure your project with a command like this (assuming the name of the project is `cvah-helk-training-fy22`)
```bash
gcloud config set project cvah-helk-training-fy22
```

If you would like to destroy this project and all of the resources associated with it you may do the following:
```bash
cd ./terraform/setup
terraform destroy -auto-approve -var 'project_id=<PICK_A_NAME_FOR_THE_PROJECT_ID>'
```

# Build A Custom Image
This will build the customized image and store it on your account. The resulting image is about 10Gs and will cost about $0.60 to store on your account per month. This image can be utilized to launch instances with the configuration already taken care of for the most part.
```bash
cd ./packer
packer init build.pkr.hcl
packer build build.pkr.hcl 

# Example specifying a project ID:
# packer init build.pkr.hcl -var 'project_id=<USE_PROJECT_ID_FROM_TERRAFORM_APPLY>'
# packer build build.pkr.hcl -var 'project_id=<USE_PROJECT_ID_FROM_TERRAFORM_APPLY>'

```
In order to delete this image you must manually go into your account and look under compute, then images to select it for deletion. 

# Deploy, Manage, & Destroy Instances
This will allow you to deploy the custom image as an instance or instances to your account under the appropriate project.
Deploy & Manage: If you first time deployment simply spins up the resources. If you change the count it will simply add or subtract instances. 
```bash
cd ./terraform/deploy
terraform init
terraform apply -auto-approve -var 'project_id=<PICK_A_NAME_FOR_THE_PROJECT_ID>' -var 'elk_count=1'
```
Destroy
```bash
cd ./terraform/deploy
terraform destroy -auto-approve -var 'project_id=<PICK_A_NAME_FOR_THE_PROJECT_ID>'
```

