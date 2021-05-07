# This is PowerCli Script designed to create OVA Backups of a vCenter environment and store them locally.
#The Disk is then offlined for better security
#It is recommended that you attach a second Empty disk to this computer


#This calls the list of names of VMs you wish to backup. This filepath can be customized to user specifications
$ListOfNames = "C:\backup\listOfNames.txt"


#The Disk number. To find your disk number, access "diskpart" from the command line and use "find disk" to find which disk number your destination disk is.

$getDisk = 1

#ServerIP goes here:
$serverIP = "10.0.17.3"

#Grabs Username and Password from Credentials
$credential = Get-StoredCredential -Target 'vCenter'

#The Output Path Prefix - tells the script where to put the exported files
$pathToPrefix = "E:\"

#Sets backup disk to "Online"

Get-Disk $getDisk | Set-Disk -IsOffline $False

#Connect to vCenter
Connect-VIServer -Server $serverIP -Credential $credential




# This loop is the primary magic - this will loop through all the names listed in the "listofNames.txt" Add all vm names to this list
foreach($line in Get-Content $ListOfNames) {

    #First we need to prep the VM by deleting all snapshots, removing all media, and shutting the VM down
    Get-Snapshot $line | Remove-Snapshot -Confirm:$false

    Get-VM -Name $line | Shutdown-VMGuest -Confirm:$false
    Start-Sleep -Seconds 45

    Get-VM -Name $line | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false


    #Exports the VM locally to the specified destination. This may take a while
    Get-VM -Name $line | Export-VApp -Destination "$pathToPrefix\$line" -Format OVA -Force 

    #Restarts the VM
    Start-VM -VM $line


}


#Set the Disk to Offline
####IF YOU DO NOT WISH TO USE OFFLINE DISK IMPLEMENTATION, COMMENT THE LINE BELOW OUT!
Get-Disk $getDisk | Set-Disk -IsOffline $True

#Exit Powershell
exit

