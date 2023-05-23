function mfh-DeleteO365GroupById {
    param (
    [Parameter(Mandatory=$true)]
    [string]$idOfOffice365Group,
    [PSCredential] $cred = (Get-Credential).GetNetworkCredential()
    )
    
    Get-AzureADMSGroup -Id $idOfOffice365Group | Remove-AzureADMSGroup

    Remove-AzureADMSDeletedDirectoryObject -Id $idOfOffice365Group
}

