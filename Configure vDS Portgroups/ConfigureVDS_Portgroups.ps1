$dvSwName = 'vDSwitch VDS'  
$dvPgNames = 'vCenter Server'   
  
$dvSw = Get-VDSwitch -Name $dvSwName   
  
# Enable LBT  
foreach($pg in (Get-View -Id  $dvSw.ExtensionData.Portgroup | Where {$dvPgNames -contains $_.Name})){  
  
    $spec = New-Object VMware.Vim.DVPortgroupConfigSpec  
    $spec.ConfigVersion = $pg.Config.ConfigVersion  
    $spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting  
    $spec.DefaultPortConfig.FilterPolicy = New-Object VMware.Vim.DvsFilterPolicy  
  
    $filter = New-Object VMware.Vim.DvsTrafficFilterConfig  
    $filter.AgentName = 'dvfilter-generic-vmware'   
  
    $ruleSet = New-Object VMware.Vim.DvsTrafficRuleset  
    $ruleSet.Enabled = $true  
  
    $rule =New-Object VMware.Vim.DvsTrafficRule  
    $rule.Description = 'Traffic Drop Rule'  
    $rule.Direction = 'both' #'outgoingPackets'   
  
    $action = New-Object VMware.Vim.DvsDropNetworkRuleAction  
      
    $qualifier = New-Object VMware.Vim.DvsIpNetworkRuleQualifier  
    $qualifier.Protocol = ${6}  
    $qualifier.DestinationAddress = ${ip:192.168.9.97}  
    $qualifier.SourceAddress = ${ip:192.168.9.97}  
  
    #$action.QosTag = 4  
    $rule.Action += $action  
    $rule.Qualifier += $qualifier  
    $ruleSet.Rules += $rule    
      
  
    $filter.TrafficRuleSet = $ruleSet  
    $spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter  
  
    $pg.ReconfigureDVPortgroup($spec)  
}  