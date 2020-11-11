$RGName = "aks-rg"
$Location = "uksouth"
$ACRName = "kubejenacr"
$AKSName = "kubejenaks"
$SPName = "kubejen-sp"
$AKSVNetName = "aks-vnet"
$AKSSubnetName = "aks-subnet"

$RG = New-AzResourceGroup -name $RGName -Location $Location -Force

$ACR = New-AzContainerRegistry -Name $ACRName -ResourceGroupName $RGName -Sku Basic -Location $Location

#$AKS = New-AzAksCluster -ResourceGroupName $RGName -Name $AKSName -Location $Location -NodeCount 1 -SshKeyValue id_rsa.pub

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



$SP_PASSWD = az ad sp create-for-rbac `
    --name $SPName `
    --role Contributor `
    --scopes $ACR_REGISTRY_ID `
    --query password `
    --output tsv

$SP_ID= az ad sp show `
    --id http://$SPName `
    --query appId `
    --output tsv`


az aks create --name $AKSName `
    --resource-group $RGName `
    --generate-ssh-key `
    --node-count 1 `
    --node-vm-size Standard_D2s_v3 `
    --service-principal $SP_ID `
    --client-secret $SP_PASSWD `
    --dns-service-ip 10.0.0.10 `
    --docker-bridge-address 172.17.0.1/16 `
    --network-plugin azure `
    --network-policy azure `
    --service-cidr 10.0.0.0/16 `
    --vnet-subnet-id $SUBNET_ID `
    --output table

az aks get-credentials `
             --name $AKSName `
             --resource-group $RGName `
             --output table

# Get the id of the service principal configured for AKS
az aks show --resource-group $RGName --name $AKSName  --query "servicePrincipalProfile.clientId" --output tsv

#az aks stop --resource-group $RGName --name $AKSName