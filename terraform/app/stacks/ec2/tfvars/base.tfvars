wireguard_sg                    = <%= output('sg.sg_id') %>
efs_dns                         = <%= output('efs.efs_dns') %>
lb_arn                          = <%= output('lb.lb_arn') %>
lb_id                           = <%= output('lb.lb_id') %>
public_dns                      = <%= output('route53.public_dns') %>
target_group_arn                = <%= output('lb.target_group_arn') %>