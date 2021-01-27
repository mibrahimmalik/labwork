# Create AKS using CLI
$Prefix = "aptaks"
$RGName = "$($Prefix)-rg"
$Location = "uksouth"
$ACRName = "$($Prefix)acr"
$AKSName = $Prefix
$AKS_Workers_VNet_Name = "$($Prefix)-vnet"
$AKS_Workers_Subnet_Name = "$($Prefix)-workers-subnet"

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
az acr create --name $ACRName --resource-group $RGName
#$ACR_REGISTRY_ID = az acr show --name $ACRName --query id --output tsv

#Create AKS
az aks create --name $AKSName `
    --resource-group $RGName `
    --generate-ssh-key `
    --node-count 1 `
    --node-vm-size Standard_D2s_v3 `    
    --dns-service-ip 10.1.1.10 `
    --docker-bridge-address 172.17.0.1/16 `
    --network-plugin azure `
    --network-policy azure `
    --service-cidr 10.1.1.0/24 `
    --vnet-subnet-id $SUBNET_ID `
    --enable-managed-identity `
    --output table

# Get AKS Credentials
az aks get-credentials `
             --name $AKSName `
             --resource-group $RGName `
             --overwrite-existing
             --output table

# Get the id of the service principal configured for AKS
#az aks show --resource-group $RGName --name $AKSName  --query "servicePrincipalProfile.clientId" --output tsv

#az aks stop --resource-group $RGName --name $AKSName