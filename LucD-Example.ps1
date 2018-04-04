$vdsSwitchName = 'vds1'

$vdsPGName = 'testpg'

$vds = Get-VDSwitch -Name $vdsSwitchName
$pg = Get-VDPortgroup -Name $vdsPGName -VDSwitch $vds

$spec = New-Object VMware.Vim.DVPortgroupConfigSpec
$spec.ConfigVersion = $pg.ExtensionData.Config.ConfigVersion 
$spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting 
$spec.DefaultPortConfig.FilterPolicy = New-Object VMware.Vim.DvsFilterPolicy 

# Add rules
$filter = New-Object VMware.Vim.DvsTrafficFilterConfigSpec 
$filter.AgentName = 'dvfilter-generic-vmware'  
$filter.Operation = [VMware.Vim.ConfigSpecOperation]::add

$ruleSet = New-Object VMware.Vim.DvsTrafficRuleset 
$ruleSet.Enabled = $true  

# TCP, 192.168.7.0/24,any,port 512, port 1024, drop
$rule =New-Object VMware.Vim.DvsTrafficRule 
$rule.Description = 'Traffic Drop Rule (added by script 1)' 
$rule.Direction = 'both'

$action = New-Object VMware.Vim.DvsDropNetworkRuleAction 

$qualifier = New-Object VMware.Vim.DvsIpNetworkRuleQualifier 
$qualifier.SourceAddress = New-Object VMware.Vim.IpRange
$qualifier.SourceAddress.AddressPrefix = '192.168.7.0'
$qualifier.SourceAddress.PrefixLength = 24
$qualifier.Protocol = New-Object VMware.Vim.IntExpression
$qualifier.Protocol.Value = 6        # 1 : ICMP, 6 : TCP, 17 : UDP 
$qualifier.DestinationAddress = $null        # $null : any
$qualifier.SourceIpPort = New-Object VMware.Vim.DvsSingleIpPort
$qualifier.SourceIpPort.PortNumber = 512
$rule.Action += $action 
$rule.Qualifier += $qualifier 
$ruleSet.Rules += $rule   

# TCP, 192.168.8.0/16,192.168.9.121,any,1024-2048, allow

$rule =New-Object VMware.Vim.DvsTrafficRule 
$rule.Description = 'Traffic Allow Rule (added by script 2)' 
$rule.Direction = 'both'

$action = New-Object VMware.Vim.DvsAcceptNetworkRuleAction

$qualifier = New-Object VMware.Vim.DvsIpNetworkRuleQualifier 
$qualifier.SourceAddress = New-Object VMware.Vim.IpRange
$qualifier.SourceAddress.AddressPrefix = '192.168.8.0'
$qualifier.SourceAddress.PrefixLength = 16
$qualifier.Protocol = New-Object VMware.Vim.IntExpression
$qualifier.Protocol.Value = 6        # 1 : ICMP, 6 : TCP, 17 : UDP 
$qualifier.DestinationAddress = New-Object VMware.Vim.SingleIp
$qualifier.DestinationAddress.Address = '192.168.9.121'
$qualifier.DestinationIpPort = New-Object VMware.Vim.DvsIpPortRange
$qualifier.DestinationIpPort.StartPortNumber = 1024
$qualifier.DestinationIpPort.EndPortNumber = 2048

$rule.Action += $action 
$rule.Qualifier += $qualifier 
$ruleSet.Rules += $rule   

# Add to Spec
$filter.TrafficRuleSet = $ruleSet 
$spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter
$pg.ExtensionData.ReconfigureDVPortgroup($spec)