# A Quick Setup script for CNI on Windows
# specifically to work with containerd and buildkit

# setup NAT network
$networkName = 'nat'

# Get-HnsNetwork is available once you have enabled the 'Hyper-V Host Compute Service' feature
# which must have been done as you setup containerd
# Enable-WindowsOptionalFeature -Online -FeatureName containers -All
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All

# the default one named `nat` should be available
# created by default when enabling the containers/Hyper-V features
$natInfo = Get-HnsNetwork -ErrorAction Ignore | Where-Object { $_.Name -eq $networkName }
if ($null -eq $natInfo) {
    throw "NAT network not found, check if you enabled containers, Hyper-V features and restarted the machine"
}
$gateway = $natInfo.Subnets[0].GatewayAddress
$subnet = $natInfo.Subnets[0].AddressPrefix

$cniConfPath = "$env:ProgramFiles\containerd\cni\conf\0-containerd-nat.conf"
$cniBinDir = "$env:ProgramFiles\containerd\cni\bin"
$cniVersion = "0.3.0"

# get the CNI plugins (binaries)
mkdir $cniBinDir -Force
curl.exe -LO https://github.com/microsoft/windows-container-networking/releases/download/v$cniVersion/windows-container-networking-cni-amd64-v$cniVersion.zip
tar xvf windows-container-networking-cni-amd64-v$cniVersion.zip -C $cniBinDir

$minimalConfig = @"
{
    "cniVersion": "$cniVersion",
    "name": "$networkName",
    "type": "nat",
    "master": "Ethernet",
    "ipam": {
        "subnet": "$subnet",
        "routes": [
            {
                "gateway": "$gateway"
            }
        ]
    },
    "capabilities": {
        "portMappings": true,
        "dns": true
    }
}
"@
Set-Content -Path $cniConfPath -Value $minimalConfig
