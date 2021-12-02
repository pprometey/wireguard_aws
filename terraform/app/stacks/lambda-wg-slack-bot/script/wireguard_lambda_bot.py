import json, boto3, hmac, os, hashlib, re
from base64 import b64decode
from urllib.parse import unquote, quote
from urllib import request

bucket = "trafilea-network"
s3Client = boto3.client("s3")
lambdaClient = boto3.client('lambda')

def s3_get_file(bucket: str, key: str) -> str:
    response = s3Client.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf-8")

def process_body(body):
    elems = unquote(b64decode(body).decode("utf-8")).split('&')
    obj = {}
    for e in elems:
        key, value = e.split('=')
        obj[key] = value
    return obj

def check_sign(event):
    body = event['body']
    timestamp = event['headers']['X-Slack-Request-Timestamp']
    concat_message = ('v0:' + timestamp + ':' + body).encode()
    slack_signature = event['headers']['X-Slack-Signature']
    key = (os.environ['slack_secret']).encode()
    hashed_msg = 'v0=' + hmac.new(key, concat_message, hashlib.sha256).hexdigest()
    if (hashed_msg != slack_signature):
        return False
    return True

def get_user_email(user_id):
    try:
        url = f"https://slack.com/api/users.info?user={user_id}"
        req = request.Request(url, headers={'content-type': 'application/x-www-form-urlencoded', 'Authorization': f'Bearer {os.environ["slack_token"]}'})
        response = request.urlopen(req).read().decode("utf-8")
        return json.loads(response)["user"]["profile"]["email"]
    except:
        return None

def vpn_command(user):
    user_config_path = f"wireguard/clients/{user}/{user}.conf"    
    try:
        respuesta = s3_get_file(bucket, user_config_path)
    except:
        respuesta = f"El user {user} NO existe en la VPN. Solicita al team de infrastructura la creacion del mismo."
        pass
        
    return { 'statusCode': 200, 'body': respuesta }


WHITELIST = ["ignacio.norris", "marco.porracin"]
def vpnabm_command(action, invoking_user, email, hook):
    if action not in ['create', 'delete']:
        return { 'statusCode': 200, 'body': f"Invalid action {action}"}
    if invoking_user not in WHITELIST:
        return { 'statusCode': 200, 'body': f"Un-Authorized to {action} a user, please contact the Infrastructure Team"}

    regex = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    if not re.fullmatch(regex, email):
        return { 'statusCode': 200, 'body': "Invalid email address"}
        
    new_user, company = email.split('@')
    if 'trafilea' not in company:
        return { 'statusCode': 200, 'body': "The new user must be a member of @trafiela.com" }

    response = lambdaClient.invoke(
        FunctionName='wireguard_abm',
        InvocationType='Event',
        Payload=json.dumps({'action':action,'user': new_user, 'hook': hook})
    )
    print(response)
    return { 'statusCode': 200, 'body': f"User is being {action} ed" }

def lambda_handler(event, context):
    if check_sign(event):
        return { 'statusCode': 200, 'body': "Un-Authorized" }
    
    params = process_body(event['body'])
    if params['channel_id'][0] == 'C':
        return { 'statusCode': 200, 'body': "I'm not going public. Please DM me to get a proper answer !"}
    
    command = params['command']
    email = get_user_email(params['user_id'])
    if email is None:
        return { 'statusCode': 200, 'body': "Unable to get user email" }
        
    user, company = email.split('@')
    if 'trafilea' not in company:
        return { 'statusCode': 200, 'body': "You must be a member of @trafiela.com" }
    
    if command == '/vpn':
        return vpn_command(user)
    elif command == '/vpnadd':
        return vpnabm_command('create', user, params['text'].strip(), unquote(params['response_url']))
    elif command == '/vpnremove':
        return vpnabm_command('delete', user, params['text'].strip(), unquote(params['response_url']))
    else:
        return { 'statusCode': 200, 'body': f"Invalid command {command}"}