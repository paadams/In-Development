$vdsSwitchName = 'vds-001'

$vdsPGNames = Get-Content "C:\Temp\portgrouplist.txt"

ForEach ( $vdsPGName in $vdsPGNames )
    {
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

        # Create rule to configure traffic marking for Ingress
        $rule =New-Object VMware.Vim.DvsTrafficRule 
        $rule.Description = 'Traffic Marking (added by script 1)' 
        $rule.Direction = 'outgoingPackets' # Setting for Ingress

        $action = New-Object VMware.Vim.DvsUpdateTagNetworkRuleAction

        $qualifier = New-Object VMware.Vim.DvsIpNetworkRuleQualifier 
        $qualifier.Protocol = New-Object VMware.Vim.IntExpression

        $action.QosTag = 1
        $action.DscpTag = 8

        # Create qualifier and set Protocol to Any
        $qualifier.Protocol = $any     # Configures Protocol to Any
        $qualifier.DestinationAddress = $null   # $null : any
        $qualifier.SourceIpPort = New-Object VMware.Vim.DvsSingleIpPort

        $rule.Action += $action 
        $rule.Qualifier += $qualifier 
        $ruleSet.Rules += $rule   

        # Add to Spec
        $filter.TrafficRuleSet = $ruleSet 
        $spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter
        $pg.ExtensionData.ReconfigureDVPortgroup($spec)

    } # End ForEach