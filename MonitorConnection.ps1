param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process pwsh -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

function StartScpService
{
	Restart-Service -Name "SCP DSx Service"
}

function MainLoop
{
    $netshResult = CheckForCurrentProfile
	IF ($netshResult -ne 2) {
        Log-Message "Attempting connection"
        netsh wlan connect name="TALKTALK5F2228 2.4"
        Start-Sleep -s 2
        $netshResult = CheckForCurrentProfile
        IF ($netshResult -ne 2) {
			Log-Message "Disabling WiFi 3"
            netsh interface set interface "WiFi 3" disable
			Log-Message "Enabling WiFi 3"
            netsh interface set interface "WiFi 3" enable
            Start-Sleep -s 8
        }
    }
    ELSE {
        Log-Message "Still connected to TALKTALK5F2228 2.4"
        Start-Sleep -s 2
    }
}

function CheckForCurrentProfile {
    return (netsh wlan show interfaces | Select-String -Pattern "Profile" -AllMatches).Matches.Count
}

function Log-Message
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LogMessage
    )

    Write-Output ("{0} - {1}" -f (Get-Date), $LogMessage)
}

Clear-Host

StartScpService
while($true) {
    MainLoop
}
PAUSE