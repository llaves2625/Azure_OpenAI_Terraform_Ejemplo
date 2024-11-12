#Definicion de variables locales
locals {

  #Subs
  sub-oai1 = "XXXXXXX-XXXXXXXX-XXXXXXX-XXXXX-XXXXXXXX"

  #Tags
  default-tags = {
    CreatedBy   = "Claudio Magagnotti"
    Owner       = "Claudio Magagnotti"
    IaC         = "Terraform"
    Environment = "Test"
  }
}


#----

module "resourceGroup1" {
  source              = "./modules/resourceGroup"
  resource_group_name = "rg-openai-01"
  location            = "swedencentral"
  providers = {
    azurerm = azurerm.sub-oai1
  }
  tags = local.default-tags
}

#Open AI account y Deployment
module "openai" {
  source = "./modules/openai"
  providers = {
    azurerm = azurerm.sub-oai1
  }
  cognitive_openai_name = "OpenAiAccount01"
  resource_group_name   = "rg-openai-01"
  location              = "swedencentral"
  custom_subdomain_name = "OpenAiAccount01" #Crea un subdominio para el private endpoint

  public_access = "true"

  deployment = {
    deployment1 = {
      name          = "gpt-35-turbo-0301"
      model_format  = "OpenAI"
      model_name    = "gpt-35-turbo"
      model_version = "0301"
      scale_type    = "Standard"
      capacity      = "10"
    }
    deployment2 = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      scale_type    = "Standard"
    }
  }

  network_acls = [
    {
      default_action = "Deny" #Bloquea el acceso desde internet
      ip_rules       = [""] #Aqui se agregan los rangos públicos desde los que necesitamos consultar
      virtual_network_rules = [
        {
          subnet_id                            = "id-de-la-subnet" #Ingresar el ID del origen desde donde se consultará el modelo
          ignore_missing_vnet_service_endpoint = false
        }
      ]
    }
  ]
  /* Esto es para utilizar una zona privada ya existente.*/
  private_dns_zone = {
    name                = "dns-privado-openAi"
    resource_group_name = "rg-dns-privado-openAi"
  }

  private_endpoint = {
    pe2 = {
      name         = pe-openai1   
      vnet_rg_name = "rg-vnet-openAi"    
      vnet_name    = "vnet-openai-01"  
      subnet_name  = "subnet-openai-01" 
      private_dns_entry_enabled       = false
      private_service_connection_name = "openai1-pe-service-01"
      is_manual_connection            = false

    }
  }

  tags = local.default-tags

  depends_on = [module.resourceGroup1]

}