#CONNECTING TO YOUR AZURE SUBSCRIPTION
# module not installed by default
install-module az -force 

#   checks if module was correctly installed
get-installedmodule az 

#   to connect to azure account
connect-azaccount -TenantId 9f7f7152-af8d-455d-83f8-47b2f508b776

#   gets a list of the connected supscriptions
get-azsubscription

$sub = get-azsubscription | where-object {$_name -like "sponsorship"} | select-azsubscription


#   Which resource groups are available to us? There will be none if the sub is brand new
Get-azresourcegroup

#   to create a new resourcegroup
# A resource group in azure is a logical container where we create Azure resources. 
new-azresourcegroup -name "newtestRG" -Location "eastus"

#   shows us our newly created resource group 
get-azresourcegroup |where-object {$_.Resourcegroupname -eq "newtestRG"} | Format-Table

## WORKING WITH AZURE VIRTUAL MACHINES ##

#   specifies the resource group we want to work with
$rg = get-azresourcegroup |where-object {$_.Resourcegroupname -eq "newtestRG"} | select-object *

#   to create a new VM with simple/default settings
# Typically we choose VMs when we need more control over the computing environment. Azure VMs give us the flexibility of virtualization without having to buy and maintain the physical hardware that runs it. 
new-azvm -Name powervm2 -resourcegroupname $rg.ResourceGroupName -Location 'East US' -Image UbuntuLTS -Credential (Get-credential)

#   to get information on a vm
$vm = Get-azvm -name powervm2 -resourcegroupname $rg.Resourcegroupname -status | select-object *
$vm.status
get-azvm -name powervm2 -status

#   to stop vm from running
get-azvm -name powervm2 -resourcegroupname $rg.resourcegroupname | stop-azvm -force -nowait

# Deletes the VM
remove-azvm -name powervm2 -ResourceGroupName newtestRG -force



if(!(get-installedmodule az)){
    write-host "The module is not installed"
}
else {
    write-host "The module is installed"
}


# Tenant ID : 9f7f7152-af8d-455d-83f8-47b2f508b776
# Subscription : Microsoft Azure Sponsorship 2


















