# Deploying on remote (serverless)
## Table of Contents
  * [Required tools](#install-tools-that-gives-below)
  * [AWS configurations](#aws-configuration)
  * [Jenkins configuration](#jenkins-configuration)
  * [Possible errors](#possible-errors)


## Install tools that gives below:
- Jenkins
- Git
- Golang-migrate
- Golang
- Docker
- Terraform

## AWS configuration

- Create a new S3 bucket for backend. And also in **Terraform/ecs/main.tf**  and **Terraform/lb_vpc_rds/main.tf** files you need to change the name of the bucket. And in the bucket create 2 folders:
  - **todo-serverless-ecs**
  - **todo-serverless-lb-vpc-rds**

- Create an IAM policy with the following AWS IAM Statement with your bucket name:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::mybucket/*"
    }
  ]
}
```

- Create an IAM User with **Access key - Programmatic access** access type and following policies:
  - **AmazonEC2FullAccess**,
  - **AmazonRDSFullAccess**,
  - **IAMFullAccess**,
  - **AmazonECS_FullAccess**,
  - **CloudWatchFullAccess**, 
  - **created policy above**.

- Create EC2 key pair in **eu_north_1** region with **todo_key.pem** with **RSA** key pair type.

## Jenkins configuration
1. Install the following plugins:
- Docker pipeline
- CloudBees AWS Credentials Plugin

> Configure **Docker** use the same way:
>
>![jenkins-docker](https://user-images.githubusercontent.com/71873090/188662136-888231cd-a20a-47e2-8318-4f3a65e6b183.jpg)


2. Add credentials in **_Manage Jenkins >> Security >> Manage Credentials_**
    - AWS_EC2_S3 - as an **_AWS Credentials_** using the IAM User credentials that were created before.
    - todo_app_ssh_eu_north_1 - as a **_SSH Username with private key_** with **ubuntu** as a username and content of key pair file **todo_key.pem** as private key.
    - db_password - as a **_Secret file_** with password for DB.
    - github - as an **_Username with password_** (as a password use the **Personal Access Token**).
    - dockerHub - as a **_Username with password_** (as a password use the **Access Token**).

> Docker **Access Token** you can create here -> **_Acccount Settings >> Security >> Access Tokens_**
>
> GitHub **Personal Access Token** you can create here -> **_Settings >> Developer settings >> Persoal access tokens_**
>
> Create the GitHub **Personal Access Token** with **_Full control of private repositories_**

<br>

3. And finally, create **pipeline** job and add Jenkinsfile as a **_Pipeline script form SCM_**. using your **github** credentials saved as a Jenkins credentials.

![jenkins job settings](https://user-images.githubusercontent.com/71873090/196144997-7408dc97-66df-420a-9f6c-e213acd3e918.jpg)


## Possible errors

1. Error related to the login on DockerHub

    If you received the same error as below:

    ```
    Using the existing docker config file.Removing blacklisted property: authsRemoving blacklisted property: credsStore$ docker login -u username -p ******** https://index.docker.io/v1/

    ```

    Try to login from terminal using

    ```
    docker login
    ```

2. Command not found error

    If you have similar error with some command.

```
java.io.IOException: error=2, No such file or directory
	at java.base/java.lang.ProcessImpl.forkAndExec(Native Method)
	at java.base/java.lang.ProcessImpl.<init>(ProcessImpl.java:340)
	at java.base/java.lang.ProcessImpl.start(ProcessImpl.java:271)
	at java.base/java.lang.ProcessBuilder.start(ProcessBuilder.java:1107)
Caused: java.io.IOException: Cannot run program "docker": error=2, No such file or directory
```

**You can solve it the same way**

Edit **_/usr/local/opt/jenkins-lts/homebrew.mxcl.jenkins-lts.plist_** file as following:

```
<key>EnvironmentVariables</key>     
	<dict>       
		<key>PATH</key>       
		<string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>     
	</dict>
```

<img width="582" alt="image" src="https://user-images.githubusercontent.com/71873090/182325011-cdaf2987-1c99-4b4f-b497-11a85944e9f9.png">
