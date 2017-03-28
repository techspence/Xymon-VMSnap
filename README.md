# Xymon-VMware
Gathers information from VMware using PowerCLI and uploads it to Xymon

# Details
	Queries the VMware ESXI Environment based on the host that is running the script.
	Gathers snapshot information such as Snapshot Name and Creation Date.
	Creates a new column in Xymon and depending on the age of the snapshot
	the icon will change to Red, Yellow or Green.

# Prerequisite
- Ubuntu 14.04.3 x64 
- PowerShell Version 6.0.0-alpha.16-1ubuntu1.14.04.1
- VMware PowerCLI Version 1.0 | Xymon 4.3.17
	Date	       : March 27th 2017

# Links
	- PowerShell https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md
	- VMWare PowerCLI https://labs.vmware.com/flings/powercli-core
	- Getting Started with PowerCLI http://www.virten.net/2016/10/getting-started-with-powercli-for-linux-powercli-core/
