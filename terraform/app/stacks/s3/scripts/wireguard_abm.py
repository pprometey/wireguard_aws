import boto3
from json import dumps
from sys import argv
from typing import Tuple
from ipaddress import ip_address
from subprocess import check_output

bucket = "trafilea-network"
client = boto3.client("s3")
resource = boto3.resource('s3')

def s3_delete_folder(bucket: str, prefix: str):
    """
    Removes all objects with a given prefix
    """
    bucket = resource.Bucket(bucket)
    bucket.objects.filter(Prefix=prefix).delete()

def remove_empty_lines(text: str) -> str:
    """
    Removes empty lines from a string.
    """
    return "\n".join([line for line in text.split("\n") if line.strip()])

def s3_save_file(bucket: str, key: str, text: str) -> None:
    """
    Saves a file to S3
    """
    client.put_object(Bucket=bucket, Key=key, Body=text)

def s3_get_file(bucket: str, key: str) -> str:
    """
    Downloads an object from S3
    """
    response = client.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf-8")

def s3_file_exists(bucket: str, key: str) -> bool:
    """
    Checks if a given s3 file exists.
    Key should contain a full file name.
    """
    try:
        client.head_object(Bucket=bucket, Key=key)
        return True
    except Exception as e:
        # print(e.response['Error']['Code'])
        return False

def generate_keys() -> Tuple[str,str,str]:
    """
    Generates a new set of keys for the user.
    """
    preshared_key = check_output("wg genpsk", shell=True).decode("utf-8").strip()
    privkey = check_output("wg genkey", shell=True).decode("utf-8").strip()
    pubkey = check_output(f"echo '{privkey}' | wg pubkey", shell=True).decode("utf-8").strip()
    return (preshared_key, privkey, pubkey)

def create_user(user: str):
    user_config_path = f"wireguard/clients/{user}/{user}.conf"
    if s3_file_exists(bucket, user_config_path):
        return {"error": f"{user} already exists"}
    
    preshared_key, privkey, pubkey = generate_keys()
    dns = remove_empty_lines(s3_get_file(bucket, "wireguard/dns.var"))
    endpoint = remove_empty_lines(s3_get_file(bucket, "wireguard/endpoint.var"))
    vpn_subnet = remove_empty_lines(s3_get_file(bucket, "wireguard/vpn_subnet.var"))
    allowed_ips = remove_empty_lines(s3_get_file(bucket, "wireguard/allowed_ips.var"))
    server_public_key = remove_empty_lines(s3_get_file(bucket, "wireguard/server_public.key"))
    
    last_used_ip_path = "wireguard/last_used_ip.var"
    last_used_ip = remove_empty_lines(s3_get_file(bucket, last_used_ip_path))

    wireguard_conf_path = "wireguard/wireguard.conf"
    wireguard_conf = s3_get_file(bucket, wireguard_conf_path)
    
    last_used_ip = int(last_used_ip) + 1
    new_user_ip = str(ip_address(vpn_subnet) + last_used_ip)

    user_config = f"""
[Interface]
PrivateKey = {privkey}
Address = {new_user_ip}/32
DNS = {dns}

[Peer]
PublicKey = {server_public_key}
PresharedKey = {preshared_key}
AllowedIPs = {allowed_ips}
Endpoint = {endpoint}
PersistentKeepalive=25"""

    wireguard_conf = f"""{wireguard_conf}
[Peer]
PublicKey = {pubkey}
PresharedKey = {preshared_key}
AllowedIPs = {new_user_ip}/32
    """

    s3_save_file(bucket, f"wireguard/clients/{user}/PRESHARED_KEY_{user}", preshared_key)
    s3_save_file(bucket, f"wireguard/clients/{user}/PRIV_KEY_{user}", privkey)
    s3_save_file(bucket, f"wireguard/clients/{user}/PUB_KEY_{user}", pubkey) 
    s3_save_file(bucket, wireguard_conf_path, wireguard_conf)
    s3_save_file(bucket, user_config_path, user_config)
    s3_save_file(bucket, last_used_ip_path, str(last_used_ip))
    return {"success": f"{user} created"}

def delete_user(user: str):
    user_config_path = f"wireguard/clients/{user}/{user}.conf"
    if not s3_file_exists(bucket, user_config_path):
        return {"error": f"{user} doesn't exists"}

    user_pub_key = remove_empty_lines(s3_get_file(bucket, f"wireguard/clients/{user}/PUB_KEY_{user}"))
    wireguard_conf_path = "wireguard/wireguard.conf"
    wireguard_conf = s3_get_file(bucket, wireguard_conf_path)

    wireguard_conf_splited = wireguard_conf.split("\n")
    pub_key_line = None
    for line_number,line in enumerate(wireguard_conf_splited):
        if user_pub_key in line:
            pub_key_line = line_number

    if pub_key_line is not None:
        new_wireguard_conf = "\n".join(wireguard_conf_splited[:pub_key_line-1] + wireguard_conf_splited[pub_key_line+3:])
    else:
        return {"error": "Couldn't find user pubkey"}
        
    s3_delete_folder(bucket, f"wireguard/clients/{user}/")
    s3_save_file(bucket, wireguard_conf_path, new_wireguard_conf)
    return {"success": f"{user} deleted"}

def main():
    if not len(argv) == 3:
        print("Usage: wireguard.py <create|delete> <user>")
        exit(1)
        
    command = argv[1]
    user = argv[2]
    valid_commands = ["create", "delete"]
    
    if command in valid_commands:
        if command == "create":
            print(dumps(create_user(user)))
        elif command == "delete":
            print(dumps(delete_user(user)))
    else:
        print(f"Invalid command {command}")
        print("Usage: wireguard.py <create|delete> <user>")
        exit(1)

if __name__ == "__main__":
    main()