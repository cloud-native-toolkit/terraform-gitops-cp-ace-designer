module "gitops_module" {
  source = "./module"

# ACE Designer Instance should be kicked-off after ACE Operator & cp4i-dependency

 depends_on = [module.cp_ace_operator,module.cp4i-dependencies]

 
  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  
  entitlement_key = module.cp_catalogs.entitlement_key
  #kubeseal_cert = module.gitops.sealed_secrets_cert
  kubeseal_cert = module.cert.cert

#Mandatory information: Fetch the required details from dependency management
 ace_version=module.cp4i-dependencies.ace.version
 license=module.cp4i-dependencies.ace.license
 license_use = module.cp4i-dependencies.ace.license_use

 # Mandatory requirement
 is_map_assist_required=false
 storage_class_4_couchdb=module.storage.rwo_storage_class
 storage_class_4_mapassist=module.storage.rwx_storage_class

}


