resource_group_name="rg-secureupload"
storage_account_name="stsecureupload"
container_name="intake"


servicePrincipalAppId=$(az account show  --query "user.name" -o tsv)
storage_account_id=$(sh ./az-storage-account-id.sh $storage_account_name)
container_id=$(sh ./az-storage-account-container-id.sh $storage_account_name $container_name)

az role assignment create \
    --role "Storage Blob Data Owner" \
    --assignee $servicePrincipalAppId \
    --scope $storage_account_id