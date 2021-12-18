variable "project_id" {
    type            = string
    default         = "cvah-helk-training"
}

source "googlecompute" "elk" {  
    image_name		= "cvah-elk-train"
    # EDIT THE PROJECT_ID FIELD TO REFLECT YOUR GCP SETUP
    project_id   	= var.project_id 
    region    		= "us-central1"
    zone    		= "us-central1-c"
    source_image 	= "ubuntu-2004-focal-v20211212"  
    machine_type 	= "n1-standard-8"
    disk_size 	 	= "50"
    # IF YOU WANT THE USER LOGON TO MATCH WHAT YOU WILL BE DEFAULT LOGON AS 
    # CHANGE THE ssh_username TO THE APPROPRIATE VALUE HERE.
    ssh_username 	= "root"  
}

build {
    sources = ["sources.googlecompute.elk"]

    provisioner "shell" {
        inline = [
            "sudo mkdir /opt/mdt",
            "sudo chown -R $(whoami):root /opt/mdt",
            "cd /opt/mdt",
            "wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.7_amd64.deb",
            "sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5.7_amd64.deb",
            "sudo apt-get update",
            "sudo apt-get -y install git kafkacat dnsutils netcat unzip",
            "date && git clone https://github.com/jwsy/HELK.git",
            "cd HELK/docker",
            "HELK_IP=$(hostname -i)",
            "time sudo ./helk_install.sh -p hunting -i $HELK_IP -b helk-kibana-notebook-analysis -l basic",
            "sudo usermod -aG docker $(whoami)",
            "cd /opt/mdt/",
            "git clone https://github.com/jwsy/mordor.git",
            "cd mordor/datasets/atomic/windows/credential_access/host/",
            "unzip empire_powerdump_sam_access.zip",
	        "sleep 180",
            "kafkacat -T -b $HELK_IP:9092 -t winlogbeat -P -l empire_powerdump_sam_access_2020-09-22042230.json",
            "sleep 30"
        ]
    }
}
