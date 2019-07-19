#Requires -Version 5

<#
.SYNOPSIS
    Install packages
.DESCRIPTION
    Install packages
.PARAMETER S3BucketName
    AWS Bucket with Public Key
.PARAMETER BastionPublicKey
    Public Key to access bastion
.NOTES
  Version:        1.0.0
  Author:         Amanda Souza
  Creation Date:  15/07/2019
#>

Param (
    [string]$S3BucketName,
    [string]$BastionPublicKey
)

echo "Importing AWS Powershell Module"
Try{
    Import-Module AWSPowershell
}
Catch{
    Write-Error "$_"
    exit
}

echo "Set HTTP, Docker and SSH Firewall Rules"
if (!(Get-NetFirewallRule | where {$_.Name -eq "Http"})) {
    New-NetFirewallRule -Name "Http" -DisplayName "Http" -Protocol tcp -LocalPort 80 -Action Allow -Enabled True
}

if (!(Get-NetFirewallRule | where {$_.Name -eq "Docker"})) {
    New-NetFirewallRule -Name "Docker" -DisplayName "Docker" -Protocol tcp -LocalPort 2375 -Action Allow -Enabled True
}

if (!(Get-NetFirewallRule | where {$_.Name -eq "Remote Desktop"})) {
    New-NetFirewallRule -Name "Remote Desktop" -DisplayName "Remote Desktop" -Protocol tcp -LocalPort 3389 -Action Allow -Enabled True
}

echo "Checking if windows openssh client is installed"
$openSsh = Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Client*' | Select-Object Name, State

if($openSsh.State -ne "Installed")
{
    Try{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.0.0.0/OpenSSH-Win64.zip -OutFile "c:\Program Files\openssh.zip"
        Expand-Archive 'c:\Program Files\openssh.zip' 'C:\Program Files\'
        cd 'C:\Program Files\./OpenSSH-Win64\'
        powershell.exe -ExecutionPolicy Bypass -File install-sshd.ps1
        New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=sshd
        netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
        net start sshd
        Powershell.exe -ExecutionPolicy Bypass -Command '. .\FixHostFilePermissions.ps1 -Confirm:$false'
        Set-Service sshd -StartupType Automatic
        Set-Service ssh-agent -StartupType Automatic
    }
    Catch{
        Write-Error "$_"
        exit
    }
}

echo "Add public key"
Try{
    mkdir "~/.ssh"
    Read-S3Object -BucketName $S3BucketName -key $BastionPublicKey  -File "~/.ssh/authorized_keys" -Region "eu-west-1"

}
Catch{
    Write-Error "$_"
    exit
}

echo "Install Docker and DockerComposer"
Try{
    Install-Module DockerMsftProvider -Force
    Install-Package Docker -ProviderName DockerMsftProvider -Force
    Start-Service docker

    #Install Docker composer
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
}
Catch{
    Write-Error "$_"
    exit
}

echo "Install Git"
Try{
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force
}
Catch{
    Write-Error "$_"
    exit
}
