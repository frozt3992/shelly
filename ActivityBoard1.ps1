#Gerardo Cortez-Martinez 
#Function of Script 
#Configures Windows to allow powershell cripts to run
#Script runs with full privelages
#Creates a New User for Client
#Configure Network Settings for Application run correctly
#Download Application and Set in Start up folder

param([switch]$Elevated) #function run script as admin mostly unnecessary but never know 

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'This is script is running with Elevated Privelages'
$UserAccount = Get-LocalUser -Name $env:USERNAME #Ensures we can use current user directory settings and credentials
$ActivityBNum = Read-Host -Prompt "Enter Activity Board Channel #" #Channel Number of Speed Screen
$Password = Read-Host -AsSecureString -Prompt "Enter Clubspeed User Password then Press Enter: " #Asks user for PW 
$UserAccount | Set-LocalUser -Password $Password
$IP = Read-Host -Prompt 'Enter IP Address'
                $MaskBits = 24 #255.255.255.0
                $Gateway = Read-Host -Prompt 'Enter Default Gateway IP'
                $Dns = Read-Host -Prompt 'Please enter the DNS Server IP'
                $IPType = "IPv4"

            # THIS WILL CHANGE FOR ALL NICS -_- gotta change and prompt for this
               $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "up"}

           # Remove any existing IP, gateway from our ipv4 adapter
 If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configured Network settings using variables created earlier
$adapter | New-NetIPAddress `
    -AddressFamily $IPType  `
    -IPAddress $IP `
    -PrefixLength $MaskBits `
    -DefaultGateway $Gateway

# Configure DNS Server using Variables created earlier
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

#Grab that App playboy ensure we are using current user 
Copy-Item "E:\ActivityBoards\channel1screen1.exe" -Destination "C:\Users\$env:username\Desktop"
Copy-Item "C:\Users\$env:username\Desktop\channel1screen1.exe" -Destination "C:\Users\$env:username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

#installs streamer (User Correct Deployment)
E:\ActivityBoards\Splashtop_Streamer_Windows_DEPLOY_INSTALLER_v3.4.4.0_SYYP5H5KLRKX prevercheck /s /i hidewindow=1

Write-Host 'Finish Splash Configuration'

#This creates a manifest at the end of each script Run
"Activity Board Channel:"+ ' ' + $ActivityBNum +',' + 'IP Address:'+" "+ $IP + " " + 'Computer Username:' + $env:USERNAME | out-file -filepath E:\Manifest\log.txt -append -width 200






