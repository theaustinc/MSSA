<#
The purpose of this script is to build an Azure VM.
The script starts off by ensuring the necessary PS module is installed.
The script then goes on to link to the tenant, select a subscription, 
    build a new resourcegroup, and finally build the virtual machine.
The last few line include some basic cmdlets to teardown what the script built,
    for testing and avoiding charges.

It would be neat to be able to run without admin priveleges. 
    Microsoft.PowerShell.SecretManagement?
    Microsoft.PowerShell.SecretStore?
#>



$isadmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isadmin -eq $false){
    write-host "Must be admin to continue"
    break
}
else {

if(!(get-installedmodule az -ErrorAction SilentlyContinue)){
    write-host "The necessary module is not installed. Would you like to install it now? (Y/N)"
    $res = Read-host
    if($res -eq "Y"){
        write-host "installing module now..."
        install-module az -force
        }    
    else {
        write-host "Ending the script..."
        break
        }
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
# But what if they want to use an existing RG?
write-host "Please specify a name for a new Resource Group..."
$newRG = Read-host
write-host "Please specify a location..."
$RGloc = Read-host
new-azresourcegroup -name $newRG -location $RGloc

# Building a new VM
# only works with ubuntults right now. why?
$rg = get-azresourcegroup | Where-Object {$_.ResourceGroupName -eq $newRG} | select-object *
Write-Host "Please specify a name for your new Virtual Machine..."
$vm = Read-host
Write-Host "Which Operating System would you like to use? [type UBUNTULTS i havent tried it with others yet]"
$OS = Read-host
new-azvm -name $vm -ResourceGroupName $rg.ResourceGroupName -Location $RGloc -Image $OS -Credential (Get-credential) 

}
#

<#
TEARDOWN
remove-azvm -name $vm -ResourceGroupName $newRG -force
remove-azresourcegroup -name $newRG -force
Disconnect-AzAccount
uninstall-module az
#>
