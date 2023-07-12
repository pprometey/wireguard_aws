# Wireguard

This repository has the terraform code necessary to create a Wireguard VPN on the network account. 
Under terraform/app/stacks you can find:
    - *sg* -> Security group that allow access to the LoadBalancer and EC2 instances
    - *s3* -> Copies /scripts folder into s3://trafilea-engine/wireguard/
    - *efs* -> Creates an EFS used as a shared storage for the instances
    - *lb* -> Creates a load balancer pointing to the escalation group
    - *route53* -> Creates a CNAME record for wireguard.trafilea.io to the balancer DNS
    - *ec2* -> Creates the escalation group and has the initial scripts the instances run to spin up wireguard

TODO: move this lambda to terraspace
There are also two lambdas:
    *wireguard_lambda_abm.py* that has the lambda that uses SSM to create/delete and refresh clients on the nodes
    *wireguard_lambda_bot.py* that handles slack commands though route53 + api gateway + invoking the other lambdas except for the basic get.
        * /vpn -> Returns the VPN configuration for the invoking user 
        * /vpnadd <email> -> Creates a new user for a given email. It does not check if its a @trafilea.com email.
        * /vpnremove <email> -> Removes a user for a given email. 
I added the JSON for the test events for *wireguard_lambda_bot.py* since it's sort of a headache to get them.
Important note, both add and remove commands have a hardcoded whitelist of who can invoke them.