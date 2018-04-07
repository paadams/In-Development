

$MyVLANFile = Import-CSV C:\Temp\new_vds_portgroups.csv

ForEach ($VLAN in $MyVLANFile) {
        $MyvSwitch = $VLAN.vDS
        $MyVLANname = $VLAN.VLANname
        $MyVLANid = $VLAN.VLANid

      

        Get-VDSwitch -Name $MyvSwitch | New-VDPortgroup -Name $MyVLANname -VlanId $MyVLANid    
        
        
    
} # End ForEach
