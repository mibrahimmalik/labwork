$group = Get-AzADGroup -ObjectId "63b7c387-0eef-49af-8708-940dd24de7f1"

$role_definition = Get-AzRoleDefinition -Name Reader

$scope = Get-AzSubscription -SubscriptionName "z_devtest"

New-AzRoleAssignment -ObjectId $group.Id -RoleDefinitionName $role_definition.Name -Scope /subscriptions/$($scope.Id)