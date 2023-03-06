# azure-vnet, virtual network appliance, local network gateway, bastion host

This guide helps you to implement the a simulated corporate network connects to virtual WAN network shown [here](https://github.com/sree7k7/azure-vwan-hub-S2S-VPN-BGP). This IaC contains only On-prem side infra. The other part VWAN network IaC is [here](https://github.com/sree7k7/azure-vwan-hub-S2S-VPN-BGP).

![diagram](/pics/VWAN-S2S-VPN-BGP.png)

## Prerequsites
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) & [sign in](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

1. First, deploy the code as it is. Later, change the parameters for VWAN hub network to establish S2S bgp enabled connection. To get the parameter values Goto virtual_hub -> VPN (Site to site) -> click: Gateway configuration shown in below pic:
```
variable "vpn_gateway_pip" {
  default = "20.166.229.221"
  description = "Destination vpn-gateway ip i,e virtual hub vpn-gateway"
}
variable "asn" {
  default = "65515"
  description = "vhub vpn-gateway asn"
}
variable "bgp_peering_address" {
  default = "10.5.0.12"
  description = "vhub vpn-gateway Default BGP IP Address"
}
variable "shared_key" {
  default = "abc@143"
}
```
![diagram](/pics/virtual_hub_vpn_configuration.png)

2. execute below commands in terminal:
   - terraform init
   - terraform plan
   - terraform apply

**Note**: If fails, try to execute: **terraform init -upgrade** on terminal and execute cmd: **terraform apply --auto-approve**.