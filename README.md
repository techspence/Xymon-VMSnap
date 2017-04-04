# Xymon-VMware
Gathers information from VMware using PowerCLI and uploads it to Xymon

# Details
Queries the VMware ESXI Environment based on the host that is running the script. Gathers snapshot information such as Snapshot Name and Creation Date. Creates a new column in Xymon and depending on the age of the snapshot the icon will change to Red, Yellow or Green.

# Prerequisite
- Ubuntu 14.04.3 x64 
- PowerShell Version 6.0.0-alpha.16-1ubuntu1.14.04.1
- VMware PowerCLI Version 1.0 | Xymon 4.3.17

# Links
- [PowerShell on Linux](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md)
- [VMWare PowerCLI](https://labs.vmware.com/flings/powercli-core)
- [Getting Started with PowerCLI](http://www.virten.net/2016/10/getting-started-with-powercli-for-linux-powercli-core/)

# Cronjob
Runs the snapshots.ps1 script at 9am, 12pm, 3pm every day

`0 9,12,15 * * * /usr/bin/powershell /home/someuser/snapshots.ps1`

# Alerts
I didn't want super noisy alerts.This will only allow RED alerts to be sent every 4 hours from 8am - 4pm every day. Because of the way I have my cronjob setup i'm getting alerts at 9am and 1pm.

The trick to gettign the timing to work is to put the REPEAT on the 2nd line with the email.

`HOST=%.* SERVICE=snapshots COLOR=RED TIME=*:0800:1600`

`MAIL email@somedomain.com REPEAT=240`


# Future Enhancements
- HTML formattted output
- Snapshot creator (you need vcenter for this)
