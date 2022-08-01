# Deploying ToDo-REST-Go
- [on localhost](#deploying-on-localhost)
- [on remote](#deploying-on-remote)

## Deploying on localhost
### Install tools that gives below:
- Docker, docker-compose
- golang-migrate

## Deploying on remote
### Install tools that gives below:
- Jenkins
- Git
- Terraform
- Ansible
- Golang-migrate

### AWS configurations
- Create an IAM User with **Access key - Programmatic access** access type and **AmazonEC2FullAccess** policy
- Create EC2 key pair with **todo_key.pem** with **RSA** key pair type

### Jenkins configurations
1. Install the following plugins:
- Docker pipeline
- Terraform
- CloudBees AWS Credentials Plugin

> Configure terraform you can here **_Manage Jenkins >> Global Configuration_**
> 
> 
> And configure docker you can using the same path
>

2. Add credentials
    - AWS_TODO - as an **_AWS Credentials_** using the IAM User credentials that were created before
    - todo_key - as a **_Secret file_** with key pair file **todo_key.pem**
    - db_password - as a **_Secret file_** with password for DB
    - github - as an **_Username with password_** (as a password use the **Personal Access Token**)
    - dockerHub - as a **_Username with password_** (as a password use the **Access Token**)

> Docker **Access Token** you can create here -> **_Acccount Settings >> Security >> Access Tokens_**
>
> GitHub **Personal Access Token** you can create here -> **_Settings >> Developer settings >> Persoal access tokens_**
>
> Create the GitHub **Personal Access Token** with **_Full control of private repositories_**

3. And finally, create **pipeline** job and add Jenkinsfile as a **_Pipeline script form SCM_**
