import requests
import boto3, subprocess, json
from getpass import getpass

AWS_REGION = "eu-central-1"

session = boto3.Session(profile_name='ssm')
ssm_client = session.client("ssm", region_name=AWS_REGION)

ip = 'localhost'
sign_in_url = f'http://{ip}:8000/auth/sign-in'

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

auth_token = subprocess.check_output([
    'curl',
    '-X', 'POST',
    '-H', 'accept: application/json',
    '-H', 'Content-Type: application/json',
    '-d', json.dumps({"password": password, "username": username}),
    f'http://{ip}:8000/auth/sign-in'
]).decode("utf-8").replace('{"token":"', '').replace('"}', '') 

headers = {'Content-Type': 'application/json', 'accept': 'application/json'}
data = json.dumps({"password": password, "username": username})
r = requests.post(sign_in_url, data=data, headers=headers)

print(r)

# decode to utf-8 because of TypeError: a bytes-like object is required, not 'str'

if auth_token == '{"message":"sql: no rows in result set':
    print('\nCREDENTIALS IS INCORRECT')
    quit
else:
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
        quit
