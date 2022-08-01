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

> Configure **Terraform** you can here **_Manage Jenkins >> Global Configuration_**
>
> ![image](https://user-images.githubusercontent.com/71873090/182134652-b400410f-21a6-488c-bbc0-6d2dc405212d.png)
> 
> And configure **Docker** you can using the same path
>
>![image](https://user-images.githubusercontent.com/71873090/182134709-8cd1264d-d729-4d8f-a65f-e14abe9aba6f.png)


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

3. And finally, create **pipeline** job and add Jenkinsfile as a **_Pipeline script form SCM_**. using your **github** credentials saved as a Jenkins credentials
![telegram-cloud-photo-size-2-5420578027445795973-y](https://user-images.githubusercontent.com/71873090/182135003-7ca4a601-760b-4436-a156-204e4f67f8ff.jpg)
