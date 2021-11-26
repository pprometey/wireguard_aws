import boto3, time

def send_command(command: str, instance_id: str) -> str:
    ssm = boto3.client('ssm',region_name='us-east-1')
    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName='AWS-RunShellScript',
        Parameters={'commands': [command]}
    )
    command_id = response['Command']['CommandId']
    pending = True
    i = 0
    while pending:
        time.sleep(5)
        output = ssm.get_command_invocation(CommandId=command_id,InstanceId=instance_id)
        print(output)
        pending = output['Status'] == 'Pending' or output['Status'] == 'InProgress'
        i += 1
        if i > 5:
            print('Timeout')
            break
    return output['StandardOutputContent']


def abm_user(action: str, user: str):
    asg = boto3.client('autoscaling',region_name='us-east-1')
    asg_response = asg.describe_auto_scaling_groups(AutoScalingGroupNames=['wireguard_asg'])
    instance_ids = [k['InstanceId'] for k in asg_response['AutoScalingGroups'][0]['Instances']]
    create_out = send_command(f'cd /opt/efs/wireguard && python3 wireguard_abm.py {action} {user}', instance_ids[0])
    if 'success' in create_out:
        refresh_all()
        return { 'statusCode': 200, 'body': 'user ' + user + ' ' + action + 'ed'}
    print(create_out)
    return { 'statusCode': 400, 'body': 'user ' + user + ' ' + action + ' failed'}

def refresh_all():
    asg = boto3.client('autoscaling',region_name='us-east-1')
    asg_response = asg.describe_auto_scaling_groups(AutoScalingGroupNames=['wireguard_asg'])
    instance_ids = [k['InstanceId'] for k in asg_response['AutoScalingGroups'][0]['Instances']]
    for instance in instance_ids:
        refresh_out = send_command('cd /opt/efs/wireguard && ./refresh-clients.sh', instance)
    return 

def lambda_handler(event, context):
    if 'action' not in event:
        return { 'statusCode': 400, 'body': 'action not specified'}
    action = event['action']
    if action in ['create', 'delete']:
        if 'user' not in event:
            return { 'statusCode': 400, 'body': 'user not specified'}
        user = event['user']
        return abm_user(action, user)
    elif action == 'refresh':
        refresh_all()
        return { 'statusCode': 200, 'body': 'users refreshed'}
    else:
        return { 'statusCode': 400, 'body': 'unknown action'}