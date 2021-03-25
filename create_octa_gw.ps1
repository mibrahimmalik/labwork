$Location = "uksouth"
$RGName = "External-Apps"
$AdminUser = "okta"
$AdminPassword = "0ktaT3st1ng!"
$VMName = "oktagw01"


az vm create --name $VMName --resource-group $RGName --location $Location --image "ubuntults" --size "Standard_D2s_v3" --data-disk-sizes-gb 500 --authentication-type "password" --admin-username $AdminUser --admin-password $AdminPassword



az disk create -n Okta-AccessGateway-2020.5.0 --resource-group External-Apps \
    --location uksouth --for-upload --upload-size-bytes 236246270464 \
    --sku standard_lrs


az disk grant-access -n Okta-AccessGateway-2020.5.0 --resource-group External-Apps --access-level Write --duration-in-seconds 86400


./azcopy login --tenant-id="60d3c411-f4c9-4745-9c21-6c6380a58180"


sudo ./azcopy copy /datadrive/temp/oag_azure.vhd "https://md-impexp-lsgprp2nsfsl.z13.blob.storage.azure.net/4zqp2k4cdmmn/abcd?sv=2018-03-28&sr=b&si=4f043860-3865-4144-8002-ff16e93c61db&sig=j0fMHvqrxh6mZArAHQeUfm7o0OXbGMXE6c4LAozYxV8%3D" --blob-type PageBlob

az disk revoke-access --name "Okta-AccessGateway-2020.5.0" --resource-group "External-Apps"

az snapshot create --resource-group External-Apps --source /subscriptions/b2ad3e59-b685-4978-a4c3-58ec53a83abb/resourceGroups/EXTERNAL-APPS/providers/Microsoft.Compute/disks/Okta-AccessGateway-2020.5.0 --name Okta-AccessGateway-2020.5.0.snapshot

$RGName = "DCMS-External-Apps"
$VMName = "dcms-oag-01"
$OSDisk = "$($VMName)-osDisk"
$location = "uksouth"
$vNetRGName = "dcms-vnet-rg-01"
$vNetName = "dcms-vnet-01"
$vNetAddressPrefix = "10.1.0.0/16"
$subnetName = "dcms-vnet-01-10-1-1-0"
$subnetAddressPrefix = "10.1.1.0/24"
$AVSetName = "$($VMName)-avset" 

az group create --location uksouth --name $RGName
az group create --location uksouth --name $vNetRGName

az network vnet create --name $vNetName --resource-group $vNetRGName --location $Location --address-prefixes $vNetAddressPrefix --subnet-name $subnetName --subnet-prefixes $subnetAddressPrefix

az vm availability-set create -n "$($VMName)-avset" -g $RGName --platform-fault-domain-count 2 --platform-update-domain-count 2

az disk create --resource-group $RGName --source "/subscriptions/b2ad3e59-b685-4978-a4c3-58ec53a83abb/resourceGroups/External-Apps/providers/Microsoft.Compute/disks/Okta-AccessGateway-2020.5.0.snapshot" --name $OSDisk

az vm create --resource-group $RGName --location uksouth --name $VMName --os-type linux --attach-os-disk $OSDisk --size Standard_D4s_v3 --vnet-name $vNetName --subnet $subnetName --availability-set $AVSetName --public-ip-address ""
