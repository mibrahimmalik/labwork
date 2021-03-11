$rgName = "php-rg"
$aspName = "mibasp"
$appName = "mibapp"

az webapp deployment user set --user-name mibazdeploy --password Password1

az group create --name $rgName --location "uksouth"

az appservice plan create --name $aspName --resource-group $rgName --sku FREE --is-linux

az --% webapp create --resource-group php-rg --plan mibasp --name mibapp --runtime "PHP|7.4" -u https://github.com/shopware

az webapp deployment source config --branch master --manual-integration --name $appName --repo-url https://github.com/shopware/shopware.git --resource-group $rgName

git remote add azure https://mibazdeploy@mibphp.scm.azurewebsites.net/mibphp.git

git add . ; git commit -m "online shopping code" ; git push azure master


az group delete --resource-group $rgName