variable "resource_group_location" {
  default     = "centralindia"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

# Vnet details
variable "vnet_config" {
    type = map(string)
    default = {
      vnetname = "Vnet-tf"
      public_subnet = "PublicSubnet"      
      private_subnet = "PrivateSubnet"      
    }
}
variable "vnet_cidr" {
  default = ["10.2.0.0/16"]
}
variable "public_subnet_address" {
  default = ["10.2.1.0/24"]
}
variable "private_subnet_address" {
  default = ["10.2.2.0/24"]
}
variable "gateway_subnet_address" {
  default = ["10.2.3.0/24"]
}
variable "bastion_subnet_address" {
  default = ["10.2.4.0/24"]
}

# destination network - Change details for local network.
variable "vpn_gateway_pip" {
  default = "20.105.44.169"
  description = "Destination vpn gateway ip i,e virtual hub vpn gateway"
}
variable "asn" {
  default = 65515
  description = "vhub vpn gateway asn"
}
variable "bgp_peering_address" {
  default = "10.5.0.13"
  description = "vhub vpn gateway Default BGP IP Address"
}
variable "shared_key" {
  default = "abc@143"
}

