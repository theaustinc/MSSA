<#
The purpose of this script is to build an Azure VM.
The script starts off by ensuring the necessary PS module is installed.
The script then goes on to link to the tenant, select a subscription, 
    build a new resourcegroup, and finally build the virtual machine.
The last few line include some basic cmdlets to teardown what the script built,
    for testing and avoiding charges.
#>

if(!(get-installedmodule az -ErrorAction SilentlyContinue)){
    write-host "The correct module is not installed. Installing now..."
    ## add prompt the user if wants to install or not? 
    install-module az -force  
    } 
else {
    write-host "The module is already installed"
}

write-host "Please enter your tenant ID"
$account = Read-host
connect-azaccount -TenantId $account

$subs = get-azsubscription
if ($subs.count -gt 1){
    Write-host "Available Subscriptions:"
    get-azsubscription | Format-Table
    write-host "Which subscription would you like to use?"
    $sub = Read-host
}
else {
    $sub = get-azsubscription
}

# Building a new Resource group
write-host "Please specify a name for a new Resource Group..."
$newRG = Read-host
write-host "Please specify a location..."
$RGloc = Read-host
new-azresourcegroup -name $newRG -location $RGloc

# Building a new VM
$rg = get-azresourcegroup | Where-Object {$_.ResourceGroupName -eq $newRG} | select-object *
Write-Host "Please specify a name for your new Virtual Machine..."
$vm = Read-host
Write-Host "Which Operating System would you like to use?"
$OS = Read-host
new-azvm -name $vm -ResourceGroupName $rg.ResourceGroupName `
 -Location $RGloc -Image $OS -Credential (Get-credential) 
#

<#
TEARDOWN
remove-azvm -name $vm -ResourceGroupName $newRG -force
remove-azresourcegroup -name $newRG -force
uninstall-module az
#>
