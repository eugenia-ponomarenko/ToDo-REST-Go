import boto3, requests, json, re
from getpass import getpass

AWS_REGION = "eu-central-1"

session = boto3.Session(profile_name='ssm')
ssm_client = session.client("ssm", region_name=AWS_REGION)

ip = '18.194.163.250'
sign_in_url = f'http://{ip}:8000/auth/sign-in'

regex = '[A-Za-z0-9]*\.[A-Za-z0-9]*\.[A-Za-z0-9_]*'

parameter_name = 'Auth-ToDo'

def put_parameter(parameter_name):
    return ssm_client.put_parameter(
            Name=parameter_name,
            Description='Bearer token for todo_app',
            Value=auth_token,
            Type='SecureString',
            Overwrite=True,
            Tier='Standard')


def get_parameter(parameter_name):
    received_token = ssm_client.get_parameter(Name=parameter_name, WithDecryption=True).get('Parameter').get('Value')
    print(f"\nReceived token: {received_token}")

print('Sign in to get a token to your account/n')
username = input("Enter your username: ")
password = getpass("Enter your password: ")

headers = {'Content-Type': 'application/json', 'accept': 'application/json'}
data = json.dumps({"password": password, "username": username})
auth_token = str(requests.post(sign_in_url, data=data, headers=headers).json().get('token'))


if re.match(regex, auth_token):
    try:
        ssm_client.get_parameter(Name=parameter_name, WithDecryption=True)
        choice = input('This parameter exists in your parameter store, do you want to create new version of it? y/n: ')
        if choice == 'y':
            put_parameter(parameter_name)
    except ssm_client.exceptions.ParameterNotFound:
        put_parameter(parameter_name)
        print('\nParameter was created!!!\n')
        
    get_param_request = input("Do you want to get your token from SSM Parameter Store? y/n: ")
    if get_param_request == 'y':
        get_parameter(parameter_name)
    else:
        print("Bye")
else:
    print('\nCREDENTIALS IS INCORRECT')