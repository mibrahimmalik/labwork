$POD_Name = kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}"

$Encoded_Secret = kubectl get secret --namespace default jenkins -o jsonpath="{.data.jenkins-admin-password}"

kubectl --namespace default port-forward $POD_Name 8080:8080


[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Encoded_Secret))

$POD_NAME=kubectl get pods --namespace default -l "app=gitea-gitea" -o jsonpath="{.items[0].metadata.name}"
$POD_Name

kubectl port-forward $POD_Name 8081:3000


$POD_Name = kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}"
$POD_Name