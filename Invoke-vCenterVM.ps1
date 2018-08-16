
$Credential = Get-Credential
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName+':'+$Credential.GetNetworkCredential().Password))
$head = @{
  'Authorization' = "Basic $auth"
}

	
$r = Invoke-WebRequest -Uri https://192.168.1.162/rest/com/vmware/cis/session -Method Post -Headers $head
$token = (ConvertFrom-Json $r.Content).value
$session = @{'vmware-api-session-id' = $token}

$r1 = Invoke-WebRequest -Uri https://192.168.1.162/rest/vcenter/vm -Method Get -Headers $session
$vms = (ConvertFrom-Json $r1.Content).value
$vms
$vms.Count
