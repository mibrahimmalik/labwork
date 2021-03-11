Set-AzContext -Subscription 'z_devtest'

$vmname = 'testvm'

$userName = 'azureuser'
$userPassword = 'Password12345'

# Convert to SecureString
$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

$creds = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

$RG = New-AzResourceGroup -Name "VM_Testing" -Location uksouth -Force
$vNet = Get-AzVirtualNetwork -Name 'testing1_vnet1' -ResourceGroupName 'testing1_rg'
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'testing1_subnet1' -VirtualNetwork $vNet

$pip = New-AzPublicIpAddress -Name "$($vmname)-pip" -ResourceGroupName $RG.ResourceGroupName `
        -Location $RG.Location -AllocationMethod Dynamic

New-AzVM -Name testvm `
            -ResourceGroupName $RG.ResourceGroupName `
            -Location $rg.Location `
            -VirtualNetworkName $vNet.Name `
            -SubnetName $subnet.Name `
            -PublicIpAddressName $pip.Name `
            -Image 'MicrosoftWindowsServer:WindowsServer:2019-Datacenter-with-Containers:latest' `
            -Size 'Standard_DS3_v2' `
            -credential $creds `
            -Verbose

Get-AzPublicIpAddress `
            -ResourceGroupName $RG.ResourceGroupName  | Select IpAddress

#Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

#Invoke-Command -ComputerName 51.140.81.50 {hostname} -Credential $creds


#Test-NetConnection -ComputerName 51.140.178.81 -Port 5985 -Verbose