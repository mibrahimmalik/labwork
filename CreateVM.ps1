Set-AzContext -Subscription 'Microsoft Azure'

$VMName = 'dcms-oag-01'
$vNetRGName = 'dcms-core-rg-01'
$VMRGName = 'dcms-external-apps-rg-01' 
$vNetName = 'dcms-vnet-vm-01'
$SubnetName = 'dcms-vm-subnet-01'
$vNetAddressPrefix = '10.1.0.0/16'
$SubnetAddressPrefix = '10.1.1.0/24'
$location = 'uksouth'

$userName = 'azureuser'
$userPassword = 'Password12345'

# Convert to SecureString
$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

$VMRG = New-AzResourceGroup -Name $VMRGName -Location uksouth -Force

$vNetRG = New-AzResourceGroup -Name $vNetRGName -Location uksouth -force 


$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$vNet = New-AzVirtualNetwork -Name $vNetName -ResourceGroupName $vNetRGName -Location $location -AddressPrefix $vNetAddressPrefix -Subnet $SubnetConfig


$nsgName = "$($VMName)-nsg"

$rdpRule = New-AzNetworkSecurityRuleConfig -Name Allow_ssh -Description "Allow ssh" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22
$nsg = New-AzNetworkSecurityGroup `
   -ResourceGroupName $VMRGName `
   -Location $location `
   -Name $nsgName -SecurityRules $rdpRule


$pipName = "$($VMName)-pip"
$pip = New-AzPublicIpAddress `
   -Name $pipName -ResourceGroupName $VMRGName `
   -Location $location `
   -AllocationMethod Dynamic

$nicName = "$($VMName)-nic"
$nic = New-AzNetworkInterface -Name $nicName `
        -ResourceGroupName $VMRGName `
        -Location $location -SubnetId $vnet.Subnets[0].Id `
        -PublicIpAddressId $pip.Id `
        -NetworkSecurityGroupId $nsg.Id

$snapshot = Get-AzSnapshot -ResourceGroupName External-Apps -SnapshotName Okta-AccessGateway-2020.5.0.snapshot

$osDiskName = "$($VMName)-osDisk"

$osDisk = New-AzDisk -DiskName $osDiskName -Disk `
    (New-AzDiskConfig  -Location $location -CreateOption Copy `
	-SourceResourceId $snapshot.Id) `
    -ResourceGroupName $VMRGName

$avSet = New-AzAvailabilitySet -ResourceGroupName $VMRGName -Name "$($VMName)-avset" -Location $VMRG.Location -PlatformUpdateDomainCount 2 -PlatformFaultDomainCount 2 -Sku Aligned

$vmConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_D4s_v3" -AvailabilitySetId $avSet.id

$vm = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = Set-AzVMOSDisk -VM $vm -ManagedDiskId $osDisk.Id -CreateOption Attach -Linux

#$vm = Set-AzureAvailabilitySet -AvailabilitySetName $avSet.Name

New-AzVM -ResourceGroupName $VMRGName -Location $location -VM $vm

<#
New-AzVM -Name $VMName `
            -ResourceGroupName $VMRG.ResourceGroupName `
            -Location $VMRG.Location `
            -VirtualNetworkName $vNet.Name `
            -SubnetName $subnet.Name `
            -PublicIpAddressName $pip.Name `
            -Size 'Standard_DS3_v2' `
            -credential $creds `
            -
            -Verbose
#-Image 'MicrosoftWindowsServer:WindowsServer:2019-Datacenter-with-Containers:latest' `
#>

Get-AzPublicIpAddress `
            -ResourceGroupName $VMRG.ResourceGroupName  | Select IpAddress



#Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

#Invoke-Command -ComputerName 51.145.97.114 {hostname} -Credential $creds

#Test-NetConnection -ComputerName 51.140.178.81 -Port 5985 -Verbose


#Remove-AzResourceGroup -Name $VMRGName -Force
#Remove-AzResourceGroup -Name $vNetRGName -Force
