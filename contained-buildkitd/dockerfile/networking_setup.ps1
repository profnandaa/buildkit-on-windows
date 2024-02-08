$ErrorActionPreference="Stop"

$containerdDir = join-path $env:ProgramFiles containerd
if (!(Test-Path $containerdDir)){
	mkdir $containerdDir
}

$cniDir = Join-Path $containerdDir "cni"
$cniConfDir = Join-Path $cniDir "conf"
$cniBinDir = Join-Path $cniDir "bin"
$cniConfPath = Join-Path $cniConfDir "0-containerd-nat.conf"
if (!(Test-Path $cniBinDir)) {
	mkdir $cniBinDir
}

git clone https://github.com/Microsoft/windows-container-networking $HOME\windows-container-networking
Set-Location $HOME\windows-container-networking
git checkout aa10a0b31e9f72937063436454def1760b858ee2
make all
Copy-Item .\out\*.exe $cniBinDir\

if (!(Test-Path $cniConfDir)) {
	mkdir $cniConfDir
}

Set-Content $cniConfPath @"
{
    "cniVersion": "0.2.0",
    "name": "nat",
    "type": "nat",
    "master": "Ethernet",
    "ipam": {
        "subnet": "172.19.208.0/20",
        "routes": [
            {
                "GW": "172.19.208.1"
            }
        ]
    },
    "capabilities": {
        "portMappings": true,
        "dns": true
    }
}
"@
