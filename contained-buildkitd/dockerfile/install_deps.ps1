# Prepare windows environment for building and running containerd tests
$ErrorActionPreference="Stop"

$PACKAGES= @{ mingw = "12.2.0"; git = ""; golang = ""; make = ""}

Write-Host "Downloading chocolatey package"
curl.exe -L "https://packages.chocolatey.org/chocolatey.0.10.15.nupkg" -o 'c:\choco.zip'
Expand-Archive "c:\choco.zip" -DestinationPath "c:\choco"

Write-Host "Installing choco"
& "c:\choco\tools\chocolateyInstall.ps1"

Write-Host "Set choco.exe path."
$env:PATH+=";C:\ProgramData\chocolatey\bin"

Write-Host "Install necessary packages"

foreach ($package in $PACKAGES.Keys) {
    $command = "choco.exe install $package --yes"
    $version = $PACKAGES[$package]
    if (-Not [string]::IsNullOrEmpty($version)) {
        $command += " --version $version"
    }
    Invoke-Expression $command
}

Write-Host "Set up environment."

$userGoBin = "$HOME\go\bin"

if (!(Test-Path $userGoBin)){
	mkdir $userGoBin
}

$env:PATH+=";c:\Program Files\Git\bin;c:\Program Files\Go\bin;$userGoBin;c:\containerd\bin"

Write-Host $env:PATH

[Environment]::SetEnvironmentVariable("PATH", $env:PATH, 'User')

# Prepare Log dir
mkdir c:\Logs
