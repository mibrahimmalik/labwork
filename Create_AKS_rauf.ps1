$aksprefix = "autopilotml"
$RGName = "$($aksprefix)-aks-rg"
$Location = "North Europe"
$ACRName = "$($aksprefix)cr"
$AKSName = "$($aksprefix)aks"
$AKSVNetName = "$($aksprefix)-vnet"
$AKSSubnetName = "$($aksprefix)-subnet"

az group create -n $RGName -l $Location

#az acr create -n $ACRName --resource-group $RGName --sku basic
<#
az network vnet create `
    --resource-group $RGName `
    --name $AKSVNetName `
    --address-prefixes 10.0.0.0/8 `
    --subnet-name $AKSSubnetName `
    --subnet-prefix 10.240.0.0/16


$VNET_ID = az network vnet show `
    --resource-group $RGName `
    --name $AKSVNetName `
    --query id `
    --output tsv

$SUBNET_ID=az network vnet subnet show `
    --resource-group $RGName `
    --vnet-name $AKSVNetName `
    --name $AKSSubnetName `
    --query id `
    --output tsv
#>
#$ACR_REGISTRY_ID=az acr show --name $ACRName --query id --output tsv

az aks create --name $AKSName `
    --resource-group $RGName `
    --generate-ssh-key `
    --node-count 1 `
    --node-vm-size Standard_D2s_v3 `
    --dns-service-ip 10.0.0.10 `
    --docker-bridge-address 172.17.0.1/16 `
    --network-plugin azure `
    --network-policy azure `
    --service-cidr 10.0.0.0/16 `
    --enable-managed-identity `
    --output table

az aks get-credentials `
             --name $AKSName `
             --resource-group $RGName `
             --overwrite-existing `
             --output table

# Create Azure Storage Account for Persistant Volume
az storage account create -n "$($aksprefix)vol1" -g $RGName -l $Location --sku Standard_LRS

$AZURE_STORAGE_CONNECTION_STRING = az storage account show-connection-string -n "$($aksprefix)vol1"  -g $RGName -o tsv


# Create file share in storage account
az storage share create -n "aks-share" --connection-string $AZURE_STORAGE_CONNECTION_STRING


$STORAGE_KEY= az storage account keys list --resource-group $RGName --account-name "$($aksprefix)vol1" --query "[0].value" -o tsv

kubectl create secret generic azure-secret --from-literal=azurestorageaccountname="$($aksprefix)vol1" --from-literal=azurestorageaccountkey=$STORAGE_KEY


# Create Container registry secret
kubectl create secret docker-registry myregistrykey --docker-server=https://aiazrnmtauacr.azurecr.io --docker-username=aiazrnmtauacr --docker-password=hoW3u2vA0gil4ukWWR3+5TtWlYn47IFv

# Create Deployment
kubectl create -f .\webserver-deployment-aks.yml





#############################################

# Delete Deployment & Service
kubectl delete svc webserver ; kubectl delete deploy webserver

# Stop AKS to save cost
az aks stop --resource-group $RGName --name $AKSName
