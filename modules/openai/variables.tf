variable "cognitive_openai_name" {
  description = "Name of openAi Account"
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
}

#variable "subnet_id" {
# description = "ID of the existing subnet"
#}

#variable "cognitive_deployment_name" {
#  description = "Name for the cognitive deployment"
#}

#variable "model_name" {
#  description = "Name of the model to be deployed"
#}

#variable "use_private_endpoint" {
#  description = "Flag to determine if private endpoint should be used"
#  default     = false
#}
/*
variable "deployment_mode" {
  description = "Deployment mode: PoC or Production"
  default     = "PoC"
}
*/
variable "public_access" {
  default = false
}

variable "custom_subdomain_name" {
  default = "w2mailz"
}
variable "location" {
  description = "Name of location"
}

#variable "model_version" {
#}

variable "network_acls" {
  type = set(object({
    default_action = string
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  }))
  default     = null
  description = <<-DESCRIPTION
    type = set(object({
      default_action = (Required) The Default Action to use when no rules match from ip_rules / virtual_network_rules. Possible values are `Allow` and `Deny`.
      ip_rules                    = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Cognitive Account.
      virtual_network_rules = optional(set(object({
        subnet_id                            = (Required) The ID of a Subnet which should be able to access the OpenAI Account.
        ignore_missing_vnet_service_endpoint = (Optional) Whether ignore missing vnet service endpoint or not. Default to `false`.
      })))
    }))
  DESCRIPTION
}

variable "deployment" {
  type = map(object({
    name                   = string
    model_format           = string
    model_name             = string
    model_version          = string
    scale_type             = string
    rai_policy_name        = optional(string)
    capacity               = optional(number)
    version_upgrade_option = optional(string)
  }))
  default     = {}
  description = <<-DESCRIPTION
      type = map(object({
        name                 = (Required) The name of the Cognitive Services Account Deployment. Changing this forces a new resource to be created.
        cognitive_account_id = (Required) The ID of the Cognitive Services Account. Changing this forces a new resource to be created.
        model = {
          model_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.
          model_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Cognitive Services Account Deployment model.
        }
        scale = {
          scale_type = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
        capacity = (Optional) Tokens-per-Minute (TPM). The unit of measure for this field is in the thousands of Tokens-per-Minute. Defaults to 1 which means that the limitation is 1000 tokens per minute.
        version_upgrade_option = (Optional) Deployment model version upgrade option. Possible values are `OnceNewDefaultVersionAvailable`, `OnceCurrentVersionExpired`, and `NoAutoUpgrade`. Defaults to `OnceNewDefaultVersionAvailable`. Changing this forces a new resource to be created.
      }))
  DESCRIPTION
  nullable    = false
}

variable "private_endpoint" {
  type = map(object({
    name                               = string
    vnet_rg_name                       = string
    vnet_name                          = string
    subnet_name                        = string
    dns_zone_virtual_network_link_name = optional(string, "dns_zone_link")
    private_dns_entry_enabled          = optional(bool, false)
    private_service_connection_name    = optional(string, "privateserviceconnection")
    is_manual_connection               = optional(bool, false)
  }))
  default     = {}
  description = <<-DESCRIPTION
  A map of objects that represent the configuration for a private endpoint."
  type = map(object({
    name                               = (Required) Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created.
    vnet_rg_name                       = (Required) Specifies the name of the Resource Group where the Private Endpoint's Virtual Network Subnet exists. Changing this forces a new resource to be created.
    vnet_name                          = (Required) Specifies the name of the Virtual Network where the Private Endpoint's Subnet exists. Changing this forces a new resource to be created.
    subnet_name                        = (Required) Specifies the name of the Subnet which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created.
    dns_zone_virtual_network_link_name = (Optional) The name of the Private DNS Zone Virtual Network Link. Changing this forces a new resource to be created. Default to `dns_zone_link`.
    private_dns_entry_enabled          = (Optional) Whether or not to create a `private_dns_zone_group` block for the Private Endpoint. Default to `false`.
    private_service_connection_name    = (Optional) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created. Default to `privateserviceconnection`.
    is_manual_connection               = (Optional) Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created. Default to `false`.
  }))
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tracing_tags_enabled" {
  type        = bool
  default     = false
  description = "Whether enable tracing tags that generated by BridgeCrew Yor."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags to assign to the resource."
  nullable    = false
}
variable "default_tags_enabled" {
  type        = bool
  default     = false
  description = "Determines whether or not default tags are applied to resources. If set to true, tags will be applied. If set to false, tags will not be applied."
  nullable    = false
}
# tflint-ignore: terraform_unused_declarations
variable "tracing_tags_prefix" {
  type        = string
  default     = "avm_"
  description = "Default prefix for generated tracing tags"
  nullable    = false
}
variable "pe_subresource" {
  type        = list(string)
  default     = ["account"]
  description = "A list of subresource names which the Private Endpoint is able to connect to. `subresource_names` corresponds to `group_id`. Possible values are detailed in the product [documentation](https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource) in the `Subresources` column. Changing this forces a new resource to be created."
}
variable "private_dns_zone" {
  type = object({
    name                = string
    resource_group_name = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
  A map of object that represents the existing Private DNS Zone you'd like to use. Leave this variable as default would create a new Private DNS Zone.
  type = object({
    name                = "(Required) The name of the Private DNS Zone."
    resource_group_name = "(Optional) The Name of the Resource Group where the Private DNS Zone exists. If the Name of the Resource Group is not provided, the first Private DNS Zone from the list of Private DNS Zones in your subscription that matches `name` will be returned."
  }
DESCRIPTION
}
variable "application_name" {
  type        = string
  default     = ""
  description = "Name of the application. A corresponding tag would be created on the created resources if `var.default_tags_enabled` is `true`."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment of the application. A corresponding tag would be created on the created resources if `var.default_tags_enabled` is `true`."
}

variable "account_name" {
  type        = string
  default     = ""
  description = "Specifies the name of the Cognitive Service Account. Changing this forces a new resource to be created. Leave this variable as default would use a default name with random suffix."
}