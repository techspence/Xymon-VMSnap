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
   	Prerequisite   : Ubuntu 14.04.3 x64 | PowerShell Version 6.0.0-alpha.16-1ubuntu1.14.04.1 | VMware PowerCLI Version 1.0 | Xymon 4.3.17
	Date	       : March 27th 2017
.LINK
	- PowerShell https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md
	- VMWare PowerCLI https://labs.vmware.com/flings/powercli-core
	- Getting Started with PowerCLI http://www.virten.net/2016/10/getting-started-with-powercli-for-linux-powercli-core/
#>

# Import all the PowerCLI Modules
Get-Module -ListAvailable PowerCLI* | Import-Module

# Snapshot Age (in days)
$RED = 5
$YELLOW = 3

# Delay so icons don't go purple
$DELAY = "+20h"

# Xymon Enviornment
$ENV = hostname
$USER = "mruser"
$PASS = "my really cool password"

if ($ENV.StartsWith("development")) {
        $server = "thedevelopmentserver"
} elseif ($ENV.StartsWith("test")) {
        $server = "thetestserver"
} elseif ($ENV.StarsWith("production")) {
        $server = "theproductionserver"
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
		BREAK
	}
	
	# Get the snapshots
	$snapshot = get-vm -Name $vm.name | get-snapshot

	if (($snapshot.Length) -gt 0) {
		foreach ($snap in $snapshot) {
			# Output
			$output += "`r`n - " + $snap.created + " - \`"$($snap.name)\`""
		}
	
		$snapinfo = "`r`n" + "ESXi Server: $server" + "`r`n" + "Virtual Machine: $vmname" + "`r`n" + "Snapshot(s):" + $output + "`r`n"
	
		# Change the color of the icon based on snapshot age
		$THEDATE = Get-Date
		$REDDATE = $THEDATE.AddDays(-$RED)
		$YELLOWDATE = $THEDATE.AddDays(-$YELLOW)

		#If the snapshot(s) are older than or equal to $RED Days
		if ($snapshot.created -le $REDDATE) {
			xymon 127.0.0.1 "status${DELAY} $vmname.snapshots red Snapshot(s) Found $snapinfo`r`n(Red >= $RED days old)" > /dev/null 2>&1
		}
		#If the snapshot(s) are older than or equal to $YELLOW Days
		elseif ($snapshot.created -le $YELLOWDATE) {
			xymon 127.0.0.1 "status${DELAY} $vmname.snapshots yellow Snapshot(s) Found $snapinfo`r`n(Yellow >= $YELLOW days old)" > /dev/null 2>&1
		}
		#If the snapshot(s) are less than $YELLOW Days
		else {
			xymon 127.0.0.1 "status${DELAY} $vmname.snapshots green Snapshot(s) Found $snapinfo`r`n(Green < $YELLOW days old)" > /dev/null 2>&1
		}
	}
	# Otherwise no snapshots were found
	else {
		$snapinfo = "No snapshots found"
		xymon 127.0.0.1 "status${DELAY} $vmname.snapshots green $snapinfo"> /dev/null 2>&1
	}
}

