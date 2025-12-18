variable "ibmcloud_api_key" {
  description = "Your IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of your Kubernetes cluster"
  type        = string
  default     = "My-Kubernetes"
}

variable "datacenter" {
  description = "Classic datacenter/zone (e.g. dal10, dal12, wdc06, wdc07)"
  type        = string
  default     = "dal10"
}

variable "public_vlan_id" {
  description = "Run this command to find out public_vlan_id: ibmcloud ks vlans --zone dal10)"
  type        = string
  default     = "xyz"        # ← change this to your own or override when running
}

variable "private_vlan_id" {
  description = "Your private VLAN ID or number"
  type        = string
  default     = "xyz"        # ← change this to your own or override
}

variable "kube_version" {
  description = "Kubernetes version (null = default/latest)"
  type        = string
  default     = null
}

#Prompts user for credentials after running terraform.apply
