#Funtion of Script
#Creates a new directory labeled as the current back up date 
#Copies a directory from C:/ to any external back up labeled as "WaiverBackups"
#Can copy into multiple drives if needed. 
#Set Volume Label to "WaiverBackups"
#Error Logging optional 


$RetentionDays = 30
$SourcePath = "C:\ClubSpeed\CustomerSignatures"
$BkupVolumeLabel = "WaiverBackups"
$Date = Get-Date -Format "yyyy MMM dd hhmm tt"
$BackupDrives = (Get-Volume | Where-Object {$_.FileSystemLabel -like "*$BkupVolumeLabel*"}).DriveLetter

ForEach ($Drive in $BackupDrives) {
    
    $Letter = "$Drive" + ":\"
    
    $Destination = "$Letter" + (Get-Item -Path $SourcePath).Name
    
    IF (-not (Test-Path -Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory
    }
    Copy-Item -Path $SourcePath -Destination "$Destination\$date" -Recurse 
    #Because the Recurse parameter is used, the operation creates the scripts folder if it doesn't already exist. 
    #If the scripts folder contains files in subfolders, those subfolders are copied with their file trees intact.
    Get-ChildItem -Path $Destination | Where-Object {$_.CreationTime -lt ((Get-Date).AddDays( - $RetentionDays))} | Remove-Item -Force -Recurse #This portion deletes the new folder according to $RetentionDays
}

#$Error > C:\Logs\backuperrors.txt