# Create a new project
pushd ./terraform/setup
terraform init 
terraform apply -auto-approve
popd 

# Create the custom image 
pushd ./packer
packer init 
packer build build.pkr.hcl
popd

# Create a new instance 
pushd ./terraform/deploy
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