# Azure DevOps YAML Pipeline to Deploy Azure Infrastructure w/Terraform

This is a YAML pipeline to deploy AKS+ACR to Azure via a YAML pipeline.
Permissions are also then applied via Terraform to allow AKS to pull images from the ACR.

The Terraform functionality of the pipeline is hosted [in an external template](https://github.com/f2calv/CasCap.YAMLTemplates/blob/master/templates/jobs.terraform.publish-v1.yml) repository for re-usability.

## Prerequisites
- Your Azure DevOps project is connected to your Azure subscription with a service principle with the correct permissions to assign AcrPull permissions (higher permissions than the default!).
- Clone this repo into Azure DevOps and create a YAML pipeline using the existing pipeline file, `.azure-pipelines/azure-pipeline.yml`
- Edits;
  - In `.azure-pipelines/azure-pipeline.yml` add your information into the areas marked `TODO`.
  - In `dev/main.tf` add your information into the areas marked `TODO`.
- Then run the pipeline...

Enjoy.

_I will update this repo with more detail as and when I have time..._