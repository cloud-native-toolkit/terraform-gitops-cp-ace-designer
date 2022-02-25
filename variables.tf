
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "entitlement_key" {
  type        = string
  description = "The entitlement key required to access Cloud Pak images"
  sensitive   = true
}

#Module Specific extension
variable "is_ace_designer_required_dedicated_ns" {
  type = bool
  description = "If ACE Designer instance need to be deployed in dedicated namespace"
  default = false

  
}
variable "ace_designer_instance_namespace" {
  type = string
  description = "It is beeter to manage ACE Designer instance workload in a dedicated namespace"
  default = "gitops-cp-ace-designer"
}

variable "ace_version" {
  type        = string
  description = "The version of the ACE Designer should be installed"
  default     = ""
}

variable "license" {
  type        = string
  description = "The license string that should be used for the instance"
  default     = ""
}

variable "license_use" {
  type        = string
  description = "The possible values are CloudPakForIntegrationNonProduction or CloudPakForIntegrationProductionn"
  default     = ""
}

variable "is_map_assist_required" {
  type        = bool
  description = "To enable mapassist feature"
  default     = false
}

#If ACE Designer Instance needed to be overridden then use this
variable "ace_designer_instance_name" {
  type = string
  description = "If ACE Designer instance name needed to be overridden"
  default = ""
  
}
#If ACE Designer Instance needed to be overridden then use this
variable "storage_class_4_couchdb" {
  type = string
  description = "RWO Accessmode supported Storageclass"
  default = "portworx-db2-rwo-sc"
  
}
variable "storage_class_4_mapassist" {
  type = string
  description = "RWX Accessmode supported Storageclass"
  default = "portworx-rwx-gp-sc"
  
}