$dvSwName = 'name-of-dvsw'
$dvPgNames = 'name-of-pg'

$dvSw = Get-VDSwitch -Name $dvSwName


foreach($pg in (Get-View -Id  $dvSw.ExtensionData.Portgroup | Where {$dvPgNames -contains $_.Name})){
    $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
    $spec.ConfigVersion = $pg.Config.ConfigVersion
    $spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
    $spec.DefaultPortConfig.FilterPolicy = New-Object VMware.Vim.DvsFilterPolicy

    $filter = New-Object VMware.Vim.DvsTrafficFilterConfig
    $filter.AgentName = 'dvfilter-generic-vmware'

    $ruleSet = New-Object VMware.Vim.DvsTrafficRuleset
    $ruleSet.Enabled = $true


    $bu01ip4 = New-Object VMware.Vim.DvsTrafficRule
    $bu01ip4.Description = 'Tag AF23 to IP4 BU01'
    $bu01ip4.Direction = 'both'
    $bu01ip4Props = New-Object VMware.Vim.DvsIpNetworkRuleQualifier
    $bu01ip4Props.protocol = ${6}
    $bu01ip4Props.destinationAddress = ${ip:172.16.14.31}
    $bu01ip4.qualifier += $bu01ip4Props


    $action = New-Object VMware.Vim.DvsUpdateTagNetworkRuleAction
    $action.DSCPTag = 22


    $bu01ip4.Action += $action
    $ruleSet.Rules += $bu01ip4

    $filter.TrafficRuleSet += $ruleSet
    spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter
    $pg.ReconfigureDVPortgroup($spec)
}