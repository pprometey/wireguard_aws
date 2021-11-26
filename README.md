# Wireguard

This repository has the terraform code neceasary in order to create a Wireguard VPN on the network account. 
Under terraform/app/stacks you can find:
    - *sg* -> Security group that allow access to the LoadBalancer and EC2 instances
    - *s3* -> Copies /scripts folder into s3://trafilea-engine/wireguard/
    - *efs* -> Creates an EFS used as a shared storage for the instances
    - *lb* -> Creates a load balancer pointing to the escalation group
    - *route53* -> Creates a CNAME record for wireguard.trafilea.io to the balancer DNS
    - *ec2* -> Creates the escalation group and has the initial scripts the instances run to spin up wireguard

There is also *wireguard_lambda_abm.py* that has the lambda that uses ssm to create/delete and refresh clients on the nodes.
TODO: move this lambda to terraspace
