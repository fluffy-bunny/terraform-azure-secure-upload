az_resource_group_location = "eastus2"
az_resource_group_name = "rg-secure-upload"
az_storage_account_name = "stsecureupload"
az_plan = "plan-secure-upload"
az_app_insights = "appis-secure-upload"
az_func_name = "azfunc-secure-upload"

# export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-heidi --query value -o tsv)