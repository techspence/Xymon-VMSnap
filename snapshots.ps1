<#
.SYNOPSIS
        Gets snapshot information from ESXI and posts it to Xymon.
.DESCRIPTION
        Queries the VMware ESXI Environment based on the host that is running the script.
        Gathers snapshot information such as Snapshot Name and Creation Date.
        Creates a new column in Xymon and depending on the age of the snapshot
        the icon will change to Red, Yellow or Green.
.NOTES
        File Name      : snapshots.ps1
        Author         : Spencer Alessi
        Prerequisite   : Ubuntu 18.04 x64, Xymon 4.3.17, PowerShell Core, VMware PowerCLI
        Date           : September 5th 2019
.LINK
        - Installing Powershell Core on Linux
        https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=power$

        - Install PowerCLI on Ubuntu 18.04
        https://www.altaro.com/vmware/install-powercli-ubuntu-linux-18-04-lts/)

#>

# Import all the PowerCLI Modules
Get-Module -ListAvailable "VMware.PowerCLI" | Import-Module

# Date
$THEDATE = Get-Date

# Snapshot Age (in days)
$RED = 5
$YELLOW = 3

# Change the color of the icon based on snapshot age
$REDDATE = $THEDATE.AddDays(-$RED)
$YELLOWDATE = $THEDATE.AddDays(-$YELLOW)

# Delay so icons don't go purple
$DELAY = "+20h"

# Xymon Enviornment
$ENV = hostname
$USER = "xxx"
$PASS = "xxx"

if ($ENV.StartsWith("dev")) {
        $server = "development"
} elseif ($ENV.StartsWith("test")) {
        $server = "test"
} elseif ($ENV.StartsWith("prod")) {
        $server = "production"
} else {
        # die
}

# Make the connection
Connect-VIServer $server -user $USER -password $PASS

foreach ($vm in (get-vm)) {
        $output = ""
        $vmname = ""

        $vmguest = Get-VMGuest -vm $vm.name

        # If the VM is not running we won't be able to grab DNS Name
        try {
                $vmname = $vmguest.HostName.split('.')[0]
                $vmname = $vmname.ToUpper()
        } catch {
                # continue
        }

        # Get the snapshots
        $snapshot = get-vm -Name $vm.name | get-snapshot

        if (($snapshot.Length) -gt 0) {
                foreach ($snap in $snapshot) {
                        # Snapshot size
                        $snapshotsize = [math]::Round($snap.SizeGB,2)

                        # Snapshot Creation Date
                        $created = $snap.created

                        $daysold = ($THEDATE - $created).days
                        $hoursold = [math]::Round(($THEDATE - $created).hours / 24,2)
                        $age = "$($daysold + $hoursold) Days(s)"


                        # Snapshot output
                        $output += "`r`n - " + $snap.created + " - \`"$($snap.name)\`"" + " - " + $snapshotsize + "G$

                }

                $output
                $snapinfo = "`r`n" + "ESXi Server: $server" + "`r`n" + "Virtual Machine: $vmname" + "`r`n" + "Snapsh$



                #If the snapshot(s) are older than or equal to $RED Days
                if ($snapshot.created -le $REDDATE) {
                        xymon 127.0.0.1 "status${DELAY} $vmname.snapshots red Snapshot(s) Found $snapinfo`r`n(Red >=$
                }
                #If the snapshot(s) are older than or equal to $YELLOW Days
                elseif ($snapshot.created -le $YELLOWDATE) {
                        xymon 127.0.0.1 "status${DELAY} $vmname.snapshots yellow Snapshot(s) Found $snapinfo`r`n(Yel$
                }
                #If the snapshot(s) are less than $YELLOW Days
                else {
                        xymon 127.0.0.1 "status${DELAY} $vmname.snapshots green Snapshot(s) Found $snapinfo`r`n(Gree$
                }
        }
        # Otherwise no snapshots were found
        else {
                $snapinfo = "No snapshots found"
                xymon 127.0.0.1 "status${DELAY} $vmname.snapshots green $snapinfo" | out-null
        }
}

