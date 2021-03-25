$userName = '.\azureuser'
$userPassword = 'Password12345'

# Convert to SecureString
$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#cmd.exe /c winrm set winrm/config/Client @{AllowUnencrypted="true"}
<<<<<<< HEAD
#Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value "true" -Force
#Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
=======

#Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value "true" -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
>>>>>>> 6f5c29268d23e231ea9e41088ca0c0879b369724

# invoke script on VM using credentials
Invoke-Command -ComputerName 127.0.0.1 {hostname;whoami;winrm get winrm/config} -Credential $creds
