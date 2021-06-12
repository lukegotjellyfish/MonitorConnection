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
		Attempt-Connect
        Start-Sleep -s 2
        $netshResult = CheckForCurrentProfile
        IF ($netshResult -ne 2) {
			Log-Message "Disabling WiFi 3"
            netsh interface set interface "WiFi 3" disable
			Start-Sleep -s 2

			Log-Message "Enabling WiFi 3"
            netsh interface set interface "WiFi 3" enable
			Log-Message "Sleeping for 8 seconds"
            Start-Sleep -s 8
			
			Attempt-Connect
			Start-Sleep -s 4
        }
    }
    ELSE {
        Log-Message "Still connected to TALKTALK5F2228"
		Log-Message "Sleeping for 2 seconds"
        Start-Sleep -s 2
    }
}

function CheckForCurrentProfile {
    return (netsh wlan show interfaces | Select-String -Pattern "Profile" -AllMatches).Matches.Count
}

function Attempt-Connect {
	Log-Message "Attempting connection"
	netsh wlan connect name="TALKTALK5F2228"
	Log-Message "Sleeping for 2 seconds"	
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