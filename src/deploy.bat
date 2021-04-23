@echo off
SET rg_name1="ipfs11234"
SET region=northeurope
echo "IPFS RG1 = " + %rg_name1%

echo "Logging into Azure..."
az.cmd login 	

# select subscription id, uncomment the line below.
az.cmd account set --subscription e13a9a25-d1ea-4fc4-8fe1-a0fe0aa6700a

echo "Creating resource group "%rg_name1%" ..."
az.cmd group create -l $region -n $rg_name1

echo "Creating the storage account "$rg_name1" ..."
# create storage account, name it the same as the resource group for simplicity
az.cmd storage account create -n $rg_name1 -g $rg_name1 -l $region --sku Standard_GRS

# get storage account key
echo "Retrieving storage account primary key..."
storageAccountKey=$(az.cmd storage account keys list \
    --resource-group $rg_name1 \
    --account-name $rg_name1 \
    --query "[0].value" | tr -d '"')

ipfsdatashare="ipfsdata"
echo "Creating IPFS data share: "$ipfsdatashare" for storage account: "$rg_name1

az.cmd storage share create \
    --account-name $rg_name1 \
    --account-key $storageAccountKey \
    --name $ipfsdatashare \
    --quota 1024 \
    --output none

ipfsexportshare="ipfsexport"
echo "Creating IPFS export share: "$ipfsexportshare" for storage account: "$rg_name1

az.cmd storage share create \
    --account-name $rg_name1 \
    --account-key $storageAccountKey \
    --name $ipfsexportshare \
    --quota 1024 \
    --output none

echo "Creating container group"
az.cmd container create --resource-group $rg_name1 \
--name ipfs1 \
--dns-name-label $rg_name1 \
--image ipfs/go-ipfs \
--os-type Linux \
--cpu 2 \
--memory 4 \
--restart-policy Always \

az.cmd container create --resource-group $rg_name1 --name ipfs1 --dns-name-label $rg_name1 --image ipfs/go-ipfs --os-type Linux --cpu 2 --memory 4 --restart-policy Always --ports 4001 5001 8080 --azure-file-volume-account-key $storageAccountKey --azure-file-volume-account-name $rg_name1 --azure-file-volume-mount-path /data/ipfs --azure-file-volume-share-name ipfsdata




echo "Done"

