# $ErrorActionPreference="Stop"

$containerdDir = join-path $env:ProgramFiles containerd
if (!(Test-Path $containerdDir)){
	Write-Warning "containerd directory not found: $containerdDir"
}

$cniDir = Join-Path $containerdDir "cni"
$cniConfDir = Join-Path $cniDir "conf"
$cniBinDir = Join-Path $cniDir "bin"
$cniConfPath = Join-Path $cniConfDir "0-containerd-nat.conf"
if (!(Test-Path $cniBinDir)) {
	Write-Warning "CNI not setup correctly: $cniBinDir, $cniConfPath"
}

# script to start:
# - containerd
# - buildkitd

# start containerd
# Start-Process -FilePath .\bin\containerd.exe -NoNewWindow -PassThru # -ArgumentList ""
Start-Process -FilePath .\bin\containerd.exe -PassThru -ArgumentList "--log-level debug --service-name containerd --log-file C:/Windows/Temp/containerd.log"

# start buildkit
#Start-Process -FilePath .\bin\buildkitd.exe -NoNewWindow
& .\bin\buildkitd.exe --debug --containerd-worker=true # --containerd-cni-config-path=$cniConfPath --containerd-cni-binary-dir=$cniBinDir --service-name buildkitd
# Start-Process -FilePath .\bin\buildkitd.exe -ArgumentList "--debug --containerd-worker=true --containerd-cni-config-path=$cniConfPath --containerd-cni-binary-dir=$cniBinDir --service-name buildkitd"
