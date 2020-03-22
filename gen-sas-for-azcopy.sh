die () {
    echo >&2 "$@"
    echo "$ ./gen-sas-for-azcopy.sh [storage-account-name] [container-name]"
    exit 1
}
REQUIRED_ARGS=2
[ "$#" -eq $REQUIRED_ARGS ] || die "$REQUIRED_ARGS argument required, $# provided"

# ACCOUNT="stsecureupload"
# CONTAINER="intake"

ACCOUNT=$1
CONTAINER=$2

EXPIRE=$(date -u -d "1 day" '+%Y-%m-%dT%H:%M:%SZ')
START=$(date -u -d "-1 day" '+%Y-%m-%dT%H:%M:%SZ')
 

SAS=$(az storage container generate-sas --account-name "$ACCOUNT" --name "$CONTAINER" --start "$START" --expiry "$EXPIRE" --https-only --permissions acdlrw --auth-mode login --as-user)

SAS=$(sed -e 's/^"//' -e 's/"$//' <<<"$SAS")
echo $SAS 

# echo sudo azcopy cp "upload" "https://stsecureupload.blob.core.windows.net/intake/v001/a/b/?$SAS" --recursive=true --put-md5
 
# sudo azcopy cp "upload" "https://stsecureupload.blob.core.windows.net/intake/v001/a/b/?$SAS" --recursive=true --put-md5
# export AZURE_STORAGE_SAS_TOKEN=$(az storage container generate-sas --account-name stsecureupload  --name intake --permissions acdlrw     --start "$START" --expiry "$EXPIRE"    --auth-mode login     --as-user)
