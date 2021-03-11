$RGName = "aks-rg"
$Location = "uksouth"
$aksprefix = "mibaks"
$ACRName = "$($aksprefix)cr"
$AKSName = $aksprefix
$SPName = "$($aksprefix)-contributor-sp"
$AKSVNetName = "aks-vnet"
$AKSSubnetName = "aks-subnet"

az group create -n $RGName -l $Location

az acr create -n $ACRName --resource-group $RGName --sku basic

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

$ACR_REGISTRY_ID=az acr show --name $ACRName --query id --output tsv

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
    --vnet-subnet-id $SUBNET_ID `
    --enable-managed-identity `
    --output table

az aks get-credentials `
             --name $AKSName `
             --resource-group $RGName `
             --output table