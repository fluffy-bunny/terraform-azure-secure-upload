![fluffy-bunny-banner](https://raw.githubusercontent.com/fluffy-bunny/static-assets/master/fluffy-bunny-banner.png)  
# terraform-azure-backend-setup
Sets up an Azure storage account to use for terraform state management is a 2 step process.
1. Create a service principal that has the rights to create resources in a given subscription.
2. Setup azure to store terraforms state.  A tutorial can be found [here](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend)  

Once that is done, we can then start creating resources the terraform way.  

# Reference
[terraform service_principal_client_secret](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)  
[github action azure login](https://github.com/Azure/login)  

# Setup you service principal
```bash
az login
az account set --subscription="<SUBSCRIPTION_ID>"
az ad sp create-for-rbac --name sp-terraform-subscription-<SUBSCRIPTION_ID>  --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>  -sdk-auth"  

produces.

{
  "clientId": "<GUID>",
  "clientSecret": "<GUID>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>",
  (...)
}
  
```
This will create a service principal, which you can see in AD App Registration that has the rights to create resources in the subscription.  

# TODO
I had to manually assign "Owner" role at the subscription level to the SP, so that I could later add "Storage Blob Owner" to this sp at the storage account scope.




# Secrets
[project secrets](https://github.com/fluffy-bunny/terraform-azure-backend-setup/settings/secrets)
to use azure login, please follow the following instructions.
[github action azure login](https://github.com/Azure/login)  

As of this writing I have not been able to get terraform to work with azure managed identity.  Service Principals auth works.

The github actions need to set the following environment variables, which are all secrets;
```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

By convention, add the secrets you produced by creating the rbac service principal and add them like you added AZURE_CREDENTIALS.
```
ARM_CLIENT_ID = <GUID>
ARM_CLIENT_SECRET = <GUID>
ARM_SUBSCRIPTION_ID = <GUID>
ARM_TENANT_ID = <GUID>
```  

The [github action](.github/workflows/terraform-tstate-setup.yml) will pull this data from secrets and export it to environment variables.  

# Azure Storage of Terraform State.  

following the [tutorial](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend) I have create a [bash script](bash/setup.sh) which gets called from our [github action](.github/workflows/terraform-tstate-setup.yml)  

The end state of the script produces a Key Vault and StorageAccount in a resource group dedicated to just terraform.  
the following script is then run downstream so that terraform knows where to store state;  
```
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-<FRIENDLY_NAME> --query value -o tsv)
```
For terraform to run the following exports need to be present;  
```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name ${{ env.VAULT_NAME }} --query value -o tsv)
export ARM_CLIENT_ID='${{secrets.ARM_CLIENT_ID}}'
export ARM_CLIENT_SECRET='${{secrets.ARM_CLIENT_SECRET}}'
export ARM_SUBSCRIPTION_ID=$(az account show --query id | xargs)
export ARM_TENANT_ID=$(az account show --query tenantId | xargs)
```
since I do an Azure Login, I just pull some of the ID's based on the current logged in principal.  

The following gets a SAS token that is compatible with azcopy.  
```bash

AZURE_STORAGE_SAS_TOKEN=$(./gen-sas-for-azcopy.sh)

sudo azcopy cp "upload" "https://stsecureupload.blob.core.windows.net/intake/v001/a/b/?$AZURE_STORAGE_SAS_TOKEN" --recursive=true --put-md5

```

# Run Local
```bash
act --env-file my.env -P ubuntu-latest=nektos/act-environments-ubuntu:18.04   
```  
