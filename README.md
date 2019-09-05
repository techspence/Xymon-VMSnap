# Xymon-VMware
Gathers information from VMware using PowerCLI and uploads it to Xymon

# Details
Queries the VMware ESXI Environment based on the host that is running the script. Gathers snapshot information such as Snapshot Name and Creation Date. Creates a new column in Xymon and depending on the age of the snapshot the icon will change to Red, Yellow or Green.

# Prerequisite
- Ubuntu 18.04 x64 
- Xymon 4.3.17
- PowerShell Core
- VMware PowerCLI

# Links
- [Installing Powershell Core on Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6#ubuntu-1804)
- [Install PowerCLI on Ubuntu 18.04](https://www.altaro.com/vmware/install-powercli-ubuntu-linux-18-04-lts/)


# Installing PowerShell Core on Linux
Run the following commands on the linux terminal.

**1. Download the Microsoft repository GPG keys**

`wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb`

**2. Register the Microsoft repository GPG keys**

`sudo dpkg -i packages-microsoft-prod.deb`

**3. Update the list of products**

`sudo apt-get update`

**4. Enable the "universe" repositories**

`sudo add-apt-repository universe`

**5. Install PowerShell**

`sudo apt-get install -y powershell`

**6. Start PowerShell, very that it runs**

`pwsh`

# Installing PowerCLI

1. Open a terminal in linux and run pwsh to start Powershell

2. Open a terminal and run the following command, select Y at the prompt to continue

	```PowerShell Install-Module -Name VMware.PowerCLI```

3. To test if the installation was successful run

	```PowerShell Get-Module VMware.PowerCLI -ListAvailable```

4. To avoid a having certificate errors prevent you from connecting to a esxi Server run

	```PowerShell Set-PowerCLIConfiguration -InvalidCertificateAction Ignore```

# Cronjob
Runs the snapshots.ps1 script at 9am, 12pm, 3pm every day

`0 9,12,15 * * * /usr/bin/pwsh /home/someuser/snapshots.ps1`

# Alerts
I didn't want super noisy alerts.This will only allow RED alerts to be sent every 4 hours from 8am - 4pm every day. Because of the way I have my cronjob setup i'm getting alerts at 9am and 1pm.

The trick to gettign the timing to work is to put the REPEAT on the 2nd line with the email.

`HOST=%.* SERVICE=snapshots COLOR=RED TIME=*:0800:1600`

`MAIL email@somedomain.com REPEAT=240`
