# Table of Contents
* [Deploying on premise](#deploying-on-localhost)
* [Deploying on remote](#deploying-on-remote)
    * [Required tools](#install-tools-that-gives-below)
    * [AWS configurations](#aws-configuration)
    * [Jenkins configuration](#jenkins-configuration)
    * [Possible errors](#possible-errors)
* [Deploying on premise with K8s](K8s/README.md)

* [Python script to save your authentication bearer token in AWS SSM Parameter Store](#python-script-to-save-your-authentication-bearer-token-in-aws-ssm-parameter-store)

# Deploying on localhost
### Install tools that gives below:
- Docker, docker-compose
- golang-migrate

And execute the following command:
```
make migrate && make run
```

# Deploying on remote
## Install tools that gives below:
- Jenkins
- Git
- Terraform
- Ansible
- Golang-migrate
- Docker

## AWS configuration
- Create an IAM User with **Access key - Programmatic access** access type and **AmazonEC2FullAccess** policy
- Create EC2 key pair with **todo_key.pem** with **RSA** key pair type

## Jenkins configuration
1. Install the following plugins:
- Docker pipeline
- CloudBees AWS Credentials Plugin

> Configure **Docker** use the same way:
>
>![jenkins-docker](https://user-images.githubusercontent.com/71873090/188662136-888231cd-a20a-47e2-8318-4f3a65e6b183.jpg)


2. Add credentials in **_Manage Jenkins >> Security >> Manage Credentials_**
    - AWS-EC2 - as an **_AWS Credentials_** using the IAM User credentials that were created before
    - todo_key - as a **_Secret file_** with key pair file **todo_key.pem**
    - db_password - as a **_Secret file_** with password for DB
    - github - as an **_Username with password_** (as a password use the **Personal Access Token**)
    - dockerHub - as a **_Username with password_** (as a password use the **Access Token**)

> Docker **Access Token** you can create here -> **_Acccount Settings >> Security >> Access Tokens_**
>
> GitHub **Personal Access Token** you can create here -> **_Settings >> Developer settings >> Persoal access tokens_**
>
> Create the GitHub **Personal Access Token** with **_Full control of private repositories_**

<br>

3. And finally, create **pipeline** job and add Jenkinsfile as a **_Pipeline script form SCM_**. using your **github** credentials saved as a Jenkins credentials
![telegram-cloud-photo-size-2-5420578027445795973-y](https://user-images.githubusercontent.com/71873090/182135003-7ca4a601-760b-4436-a156-204e4f67f8ff.jpg)

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

<br>

# Python script to save your Authentication Bearer token in AWS SSM Parameter Store
- With this script you can put token as a parameter in AWS SSM Parameter Store
- And get this parameter from the Parameter Store

1. Create an IAM policy with the following permissions:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:PutParameter"
            ],
            "Resource": "*"
        }
    ]
}
```
2. Create an IAM User for boto3 with this policy and **Access key - Programmatic access** access type.
3. Add credentials for **aws** as following:

```
> aws configure --profile ssm
AWS Access Key ID [None]: AKIASA************
AWS Secret Access Key [None]: jS+ZbKn***********************
```

4. Change an **url** value to your Public IP if you [deploy on remote](#deploying-on-remote) or leave the same one.
    
5. Execute the [aws-ssm.py](aws-ssm.py) script.

> This script uses **sign-in** to get the token, so if you want to get a token from a specific account, don't forget to create it in the API first. You can do this from a link **url:8000/swagger/index.html** using the **sign-up** command in **auth** section.