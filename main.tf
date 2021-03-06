locals {

  # If decided to create the ACE Designer instance in the dedicated namepace 
  namespace = var.namespace
  is_map_assist_enabled=var.is_map_assist_required
  
  name          = "gitops-cp-ace-designer"
  bin_dir       = module.setup_clis.bin_dir
  base_name          = "ibm-ace"
  
  # If the name of an ACE Designer is overridden then choose the overridden value
  instance_name = var.ace_designer_instance_name != "" ? var.ace_designer_instance_name : "${local.base_name}-designer"

  chart_name="ibm-ace-designer" 
  instance_chart_dir = "${path.module}/charts/${local.chart_name}"
  yaml_dir           = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name}"
  

  service_url   = "http://${local.name}.${local.namespace}"
  
  values_content={
    ibm_ace_designer={
      isMapAssistRequired=local.is_map_assist_enabled
      name=local.instance_name
      license={
        accept = true
        license=var.license
        use=var.license_use
      }
      couchdb={
        replicas=1
        storage={
          size= "10Gi"
          type= "persistent-claim"
          class= var.storage_class_4_couchdb
        }
      }
      designerFlowsOperationMode="local"
      useCommonServices= true
      version=var.ace_version
      designerMappingAssist={
        enabled= true
        incrementalLearning={
          schedule="Every 15 days"
          useIncrementalLearning= true
          storage={
            type="persistent-claim"
            class=var.storage_class_4_mapassist
          }
        }
      }
    }
  }
  
  
  layer = "services"
  type  = "instances"
  application_branch = "main"
  values_file = "values.yaml"      


  layer_config = var.gitops_config[local.layer]
}


module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}


module pull_secret {
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  namespace=local.namespace
  docker_username = "cp"
  docker_password = var.entitlement_key
  docker_server   = "cp.icr.io"
  secret_name     = "ibm-entitlement-key"
}


resource null_resource create_yaml {
  provisioner "local-exec" {
    
    command = "${path.module}/scripts/create-yaml.sh '${local.instance_name}' '${local.instance_chart_dir}' '${local.yaml_dir}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}


resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = local.name
    #namespace = var.namespace
    namespace=local.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
