# azure-vnet, virtual network gateway, local network gateway, bastion host

This guide helps you to implement the a simulated corporate network connects to virtual WAN network shown [here](https://github.com/sree7k7/azure-vwan-hub-S2S-VPN-BGP). This IaC contains only On-prem side infra. The other part VWAN network IaC is [here](https://github.com/sree7k7/azure-vwan-hub-S2S-VPN-BGP).

![diagram](/pic/VWAN-S2S-VPN-BGP.png)

## Prerequsites

- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) & [sign in](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

1. First, deploy the code as it is. Later, change the parameters for destination (VWAN hub) network to establish S2S bgp enabled connection. In destination network get the parameter values. Goto virtual_hub → VPN (Site to site) → click: Gateway configuration → VPN Gateway instace-0/1 shown in below pic:

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

![diagram](/pic/virtual_hub_vpn_configuration.png)

2. execute below commands in terminal:
   - terraform init
   - terraform plan
   - terraform apply
3. Update the parameter values and execute: *terraform apply*

**Note**: If fails, try to execute: **terraform init -upgrade** on terminal and execute cmd: **terraform apply --auto-approve**.

4. Verify the connection:
   - Navigate to Virtual Network Gateway.
   - Click: BGP peers status (shown in below pic)
  ![diagram](/pic/BGP_peer_verify.png)

- And navigate to **Connections** and check lgw status.

5. Connect the VM using bastion host.
   - username: demousr
   - passowrd: Password@123

6. Reachout the destination vm using private ip.
