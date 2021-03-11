$userName = '.\azureuser'
$userPassword = 'Password12345'

# Convert to SecureString
$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#cmd.exe /c winrm set winrm/config/Client @{AllowUnencrypted="true"}

Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value "true" -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# invoke script on VM using credentials
Invoke-Command -ComputerName 127.0.0.1 {hostname} -Credential $creds