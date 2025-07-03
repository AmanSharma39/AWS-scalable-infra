# 🌿 Leafny Scalable Web Hosting Infrastructure (Terraform)

This project provisions a fully automated, scalable, and monitored cloud infrastructure on **AWS** to host a basic `Hello World` web page. Built using **Terraform**, it includes auto-recovery, logging, and email alerts — ideal for internal or client deployments.

---

## 🚀 Features

- **EC2 Instance** 
- **Elastic IP** for consistent public access
- **Attached EBS Volume** for persistent storage
- **Auto Scaling Group** based on CPU usage
- **AMI Creation** for consistent scaling
- **CloudWatch Monitoring** (CPU, memory, disk, web logs)
- **IAM Roles** for CloudWatch agent
- **Stateless & Auto-Healing Deployment**

---

## 🗂 Project Structure

```bash
leafny-infra/
│
├── provider.tf                  
├── keypair.tf                  
├── security-group.tf           
├── ec2-instance.tf              
├── ebs.tf                       
├── elastic-ip.tf               
├── iam-cloudwatch.tf           
├── ami.tf                       
├── launch-template.tf          
├── autoscaling.tf                                            
├── variables.tf              
├── outputs.tf                  
└── init.sh                   
```

## 🛠 How to Use

### 1. 🧰 Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed
- A valid SSH key pair in `~/.ssh/id_rsa.pub` (or adjust path in `keypair.tf`)

---

### 2. 📦 Initialize Terraform

```bash
terraform init
```
### 3. 🔍 Review the Plan

### 4. 🚀 Apply Infrastructure
```bash
terraform apply
```
Then confirm with yes.

### 5. Resources created 
* INSTANCE

    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234028.png?raw=true)

* SUBNETS
    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234536.png?raw=true)

* AUTO SCALING GROUP
    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234834.png?raw=true)

* SECURITY GROUP
    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234858.png?raw=true)

* AMI
    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234913.png?raw=true)

* LAUNCH TEMPLATE
    ![INSTANCE](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234931.png?raw=true)

### 6. 🌐 Access Web Page

Once deployed, visit the Elastic IP shown in the output in your browser.
You should see a simple "Hello World from Leafny" page.

![deploy image](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234740.png?raw=true)
### 🧹 Clean Up
```bash
terraform destroy
```
![detroy](https://github.com/AmanSharma39/AWS-scalable-infra/blob/main/images/Screenshot%202025-07-03%20234516.png?raw=true)
### 🔒 Security
* Only ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) are open

* IAM roles are used to restrict access only to necessary services (CloudWatch)
