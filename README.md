# Bot Telegram: Find Objects In Photo - DevOps
## Table of contents
  1. [About the project](#About-the-project)
  2. [Skills demonstrated](#Skills-demonstrated)
  3. [Technologies used](#Technologies-used)
  4. [Getting started](#Getting-started)
  5. [Usage](#Usage)
  7. [Future improvements](#Future-improvements)

## About the project
This project showcases a Telegram bot capable of analyzing images sent to it. Using the YOLOv5 AI model, the bot detects objects in the image and returns a list of identified objects to the user. The project demonstrates advanced DevOps capabilities, including infrastructure provisioning as code (IaC) in AWS using Terraform. The connection process is managed with Ansible, which connects to each EC2 instance and deploys the relevant Docker container, whether it is the AI model or the Telegram bot server.

## Skills demonstrated
- **Infrastructure as Code (IaC):**
  Designed and deployed cloud infrastructure on AWS using Terraform, showcasing expertise in defining resources programmatically and automating deployment processes.
- **Configuration Management:**
  Utilized Ansible to automate instance provisioning and deploy Docker containers across EC2 instances efficiently.
- **Continuous Integration and Deployment (CI/CD):**
  Developed a GitHub Actions workflow to automate deployment, ensuring smooth updates to infrastructure and application components.
- **Docker Containerization:**
  Packaged the AI model and Telegram bot server into Docker containers, optimizing portability and scalability.
- **AI Integration:**
  Integrated the YOLOv5 model for object detection, demonstrating experience with AI models and image processing.
- **Cloud Computing:**
  Leveraged AWS services for reliable and scalable deployment of infrastructure and application components.

## Technologies used
- **AWS Services:**
  - <img src="https://icon.icepanel.io/AWS/svg/App-Integration/Simple-Queue-Service.svg" width="10" height="10"> **SQS** (Simple Queue Service): For message queuing and decoupling of application components.
  - **VPC** (Virtual Private Cloud): For secure and isolated networking within AWS.
  - **S3 Bucket:** For object storage and static file hosting.
  - **DynamoDB:** A NoSQL database for fast and flexible data management.
  - **Security Groups:** For controlling inbound and outbound traffic to AWS resources.
  - **IAM Roles & Policies:** For secure authentication and fine-grained access control.
  - **Instance Profile:** For attaching IAM roles to EC2 instances.
  - **Load Balancer & Target Groups:** For distributing incoming traffic across instances.
  - **ACM** (AWS Certificate Manager): For managing SSL/TLS certificates.
  - **Route53:** For domain management and routing.
  - **Auto Scaling Groups:** For maintaining high availability and scaling EC2 instances automatically.
- **Terraform:**
  Used for Infrastructure as Code (IaC) to provision and manage the AWS resources programmatically.
- **Ansible:**
For configuration management, automated provisioning, and Docker installation on EC2 instances.
- **Docker:**
  Containerization platform used to package and deploy the AI model and Telegram bot server on the EC2 instances.
- **SSH:**
  Secure protocol used for verifying EC2 instance accessibility and testing connectivity.
- **GitHub Actions:**
  CI/CD tool for automating the deployment process, including provisioning AWS infrastructure and managing Docker container deployments.
- **Linux Command-Line Tools:**
  Used for IP collection, SSH connectivity testing, and generating Ansible host files.
### Summary
The workflow demonstrates the integration of multiple advanced technologies to automate the deployment of a complex infrastructure. It combines the power of Terraform for IaC, AWS for cloud resources, Ansible for provisioning and configuration, Docker for containerization, and GitHub Actions for CI/CD automation.

## Getting started
## Usage
## Future improvements