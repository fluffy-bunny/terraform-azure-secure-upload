die () {
    echo >&2 "$@"
    echo "$ ./az-storage-account-id.sh [storage-account-name]"
    exit 1
}
[ "$#" -eq 1 ] || die "1 argument required, $# provided"
RESOURCE_GROUP_NAME="rg-secureupload"

STORAGE_ACCOUNT_NAME=$1
STORAGEID=$(az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv)
echo $STORAGEID



 