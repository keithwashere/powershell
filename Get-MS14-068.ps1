import-module activedirectory
[string]$KBNumber = "KB3011780"

$DomainControllers = Get-ADDomainController -filter *
[int]$DomainControllersCount = @($DomainControllers).Count
[int]$PatchedDCCount = 0
[int]$UnPatchedDCCount = 0
$UnpatchedDCs = @()

Write-Output "Scanning $DomainControllersCount Domain Controllers for patch $KBNumber"
ForEach ($DomainController in $DomainControllers)
    { 
        $DomainControllerHostName = $DomainController.HostName
        $PatchStatus = Get-HotFix -ID $KBNumber -ComputerName $DomainController.HostName -ErrorAction SilentlyContinue
        
        IF ($PatchStatus.InstalledOn)
            {
                $PatchStatusInstalledOn = $PatchStatus.InstalledOn
                Write-Output "$DomainControllerHostName patched on $PatchStatusInstalledOn"
                $PatchedDCCount++
            }
        Else
            {
                Write-Warning "$DomainControllerHostName is NOT patched for $KBNumber (or could not be contacted)"
                [array]$UnpatchedDCs += "$($DomainController.HostName) -> $($DomainController.OperatingSystem)"
                $UnPatchedDCCount++
            }
    }

Write-Output "Out of $DomainControllersCount DCs, Patched: $PatchedDCCount & UnPatched: $UnPatchedDCCount "
IF ($UnpatchedDCs)
    { 
        Write-Output "* * * * The following DCs are NOT patched for $KBNumber * * * *`n" 
        $UnpatchedDCs
    }

Write-Output "
* * * * The vulnerable Windows Versions are: * * * *

Windows Server 2003 Service Pack 2
Windows Server 2008 Service Pack 2
Windows Server 2008 R2 Service Pack 1
Windows Server 2012
Windows Server 2012 R2
"