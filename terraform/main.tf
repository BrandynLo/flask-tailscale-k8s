terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.0"
    }
  }
}

provider "ibm" {
  region           = "us-south"
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "default" {
  name = "Default"
}

resource "ibm_container_cluster" "free" {
  name              = var.cluster_name
  datacenter        = var.datacenter
  machine_type      = "u3c.2x4"          
  hardware          = "shared"
  public_vlan_id    = var.public_vlan_id
  private_vlan_id   = var.private_vlan_id
  default_pool_size = 1
  resource_group_id = data.ibm_resource_group.default.id

  force_delete_storage = true
  no_subnet            = true
  kube_version         = var.kube_version
  wait_till            = "normal"
}

output "cluster_info" {
  value = <<-EOT

  IBM Cloud Kubernetes cluster created!

  Name       : ${ibm_container_cluster.free.name}
  ID         : ${ibm_container_cluster.free.id}
  Datacenter : ${var.datacenter}
  Worker     : 1 × u3c.2x4 (2 vCPU + 4 GB) – forever free

  Connect now:
    ibmcloud ks cluster config --cluster ${ibm_container_cluster.free.id} --admin
    kubectl get nodes -o wide

  EOT
}
