# Create AKS using CLI
$Prefix = "aptaks"
$RGName = "$($Prefix)-rg"
$Location = "uksouth"
$ACRName = "$($Prefix)acr"
$AKSName = $Prefix
$AKS_Workers_VNet_Name = "$($Prefix)-vnet"
$AKS_Workers_Subnet_Name = "$($Prefix)-workers-subnet"

# Create Resource Group
az group create --name $RGName --location $Location


# Create vNet and Subnet for AKS
az network vnet create `
    --resource-group $RGName `
    --name $AKS_Workers_VNet_Name `
    --address-prefixes 10.1.0.0/16 `
    --subnet-name $AKS_Workers_Subnet_Name `
    --subnet-prefix 10.1.1.0/24


$AKS_Workers_VNet_Id = az network vnet show `
    --resource-group $RGName `
    --name $AKS_Workers_VNet_Name `
    --query id `
    --output tsv

$AKS_Workers_Subnet_Id = az network vnet subnet show `
    --resource-group $RGName `
    --vnet-name $AKS_Workers_VNet_Name `
    --name $AKS_Workers_Subnet_Name `
    --query id `
    --output tsv

# Create ACR
az acr create --name $ACRName --resource-group $RGName --sku Basic
#$ACR_REGISTRY_ID = az acr show --name $ACRName --query id --output tsv

#Create AKS
az aks create --name $AKSName `
    --resource-group $RGName `
    --generate-ssh-key `
    --node-count 1 `
    --node-vm-size Standard_D2s_v3 `
    --dns-service-ip 10.1.2.10 `
    --docker-bridge-address 172.17.0.1/16 `
    --network-plugin azure `
    --network-policy azure `
    --service-cidr 10.1.2.0/24 `
    --vnet-subnet-id $AKS_Workers_Subnet_Id `
    --enable-managed-identity `
    --output table

# Get AKS Credentials
az aks get-credentials `
             --name $AKSName `
             --resource-group $RGName `
             --overwrite-existing `
             --output table

# Get the id of the service principal configured for AKS
#az aks show --resource-group $RGName --name $AKSName  --query "servicePrincipalProfile.clientId" --output tsv

#az aks stop --resource-group $RGName --name $AKSName


# Create Azure Storage Account for Persistant Volume
az storage account create -n "$($Prefix)vol1" -g $RGName -l $Location --sku Standard_LRS

$AZURE_STORAGE_CONNECTION_STRING = az storage account show-connection-string -n "$($prefix)vol1"  -g $RGName -o tsv


# Create file share in storage account
az storage share create -n "aks-share" --connection-string $AZURE_STORAGE_CONNECTION_STRING


$STORAGE_KEY= az storage account keys list --resource-group $RGName --account-name "$($prefix)vol1" --query "[0].value" -o tsv

kubectl create secret generic azure-secret --from-literal=azurestorageaccountname="$($prefix)vol1" --from-literal=azurestorageaccountkey=$STORAGE_KEY


# Create Container registry secret
kubectl create secret docker-registry myregistrykey --docker-server=https://aiazrnmtauacr.azurecr.io --docker-username=aiazrnmtauacr --docker-password=hoW3u2vA0gil4ukWWR3+5TtWlYn47IFv
