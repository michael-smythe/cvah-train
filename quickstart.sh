# Prerequsites
# 1. GCP billing account name found at https://console.cloud.google.com/billing, in the examples this is `My Billing Account FY22`
# 2. Desired project ID name, in the examples this is `cvah-helk-training-fy22`

# Install deps
# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# sudo apt-get update && sudo apt-get install terraform packer

# Create a new project
pushd ./terraform/setup
# Do a plan to ensure configs are set up
# terraform init -var "gcp_billing_account_name=My Billing Account FY22" -var "project_id=cvah-helk-training-fy22"
# terraform plan -var "gcp_billing_account_name=My Billing Account FY22" -var "project_id=cvah-helk-training-fy22"
# terraform apply -auto-approve -var "gcp_billing_account_name=My Billing Account FY22" -var "project_id=cvah-helk-training-fy22"
terraform init
terraform apply -auto-approve
popd 

# If in GCP Console, set the project now that it's been created
# gcloud config set project cvah-helk-training-fy22

# Create the custom image 
pushd ./packer
# Specify the same Project ID as above
# packer init -var "project_id=cvah-helk-training-fy22" build.pkr.hcl
# packer build -var "project_id=cvah-helk-training-fy22" build.pkr.hcl
packer init build.pkr.hcl
packer build build.pkr.hcl
popd

# Create a new instance 
pushd ./terraform/deploy
# Same plan/init/apply lifecycle as above
# terraform init -var "project_id=cvah-helk-training-fy22"
# terraform apply -auto-approve -var "project_id=cvah-helk-training-fy22"
terraform init 
terraform apply -auto-approve
popd

# Wait approx 3 min for the instances to become available
echo 'THE INSTANCES HAVE BEEN CREATED BUT HELK NEEDS TIME TO SPIN UP'
echo 'WAIT APPROX 3-5 MIN FOR INSTANCES TO BE AVAILABLE.'
echo 'THE SCRIPT WILL SLEEP FOR 3 MINUTES TO LET YOU KNOW.'
sleep 180
echo 'WAITED 3 MIN SO FAR. GO AHEAD AND TRY TO CONNECT.'
echo 'THE SCRIPT WILL WAIT 2 MORE MIN TO LET YOU KNOW.'
sleep 120
echo '5 MINUTES HAS ELAPSED. IF THE SERVICES ARE NOT UP YOU MAY WANT TO LOGON'
echo 'gcloud config set project cvah-helk-training && gcloud compute ssh elk-0'
echo 'QUICK START SCRIPT EXITING NOW!'
