param(
    [Parameter(Position = 0)]
    [string]$TestDir,

    [Parameter(Mandatory = $false)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [string]$DockerfilesDir
)

# pull the base images from registry to
# avoid skew of the first pull time.
# however, buildkit has a better pull time.
$baseImageNS = "mcr.microsoft.com/windows/nanoserver:ltsc2022"
$baseImageSC = "mcr.microsoft.com/windows/servercore:ltsc2022"

docker pull $baseImageNS
docker pull $baseImageSC
ctr image pull $baseImageNS
ctr image pull $baseImageSC

$dockerBuild = "docker build -t perftest-docker-{0} {1}"
$buildctlBuild = "buildctl build --frontend dockerfile.v0 --local context={1} --local dockerfile={1} --output type=image,name=docker.io/profnandaa/perftest-bk-{0},push=false"

$results = @()

function Run($dir) {
    Write-Host "Running Test Case: $($dir.Name)"
    $dockerfileHash = Get-FileHash -Algorithm SHA256 "$($dir.FullName)\Dockerfile"

    Write-Host "== Running: $($dockerBuild -f $dir.Name, $dir.FullName)"
    $timeDockerCached = Measure-Command { Invoke-Expression ($dockerBuild -f $dir.Name, $dir.FullName) }
    Write-Host "== Running: $($dockerBuild -f $dir.Name, $dir.FullName) --no-cache"
    $timeDockerNoCache = Measure-Command {  Invoke-Expression "$($dockerBuild -f $dir.Name, $dir.FullName) --no-cache" }
    Write-Host "== Running: $($buildctlBuild -f $dir.Name, $dir.FullName)"
    $timeBuildkitCached = Measure-Command { Invoke-Expression ($buildctlBuild -f $dir.Name, $dir.FullName) }
    Write-Host "== Running: $($buildctlBuild -f $dir.Name, $dir.FullName) --no-cache"
    $timeBuildkitNoCache = Measure-Command { Invoke-Expression "$($buildctlBuild -f $dir.Name, $dir.FullName) --no-cache" }

    # store results
    return [PSCustomObject]@{
        TestCase = $dir.Name
        Hash = $dockerfileHash.Hash.ToLower().Substring(0,8)
        DockerNoCache = [int]([Math]::Round($timeDockerNoCache.TotalMilliseconds))
        BuildkitNoCache = [int]([Math]::Round($timeBuildkitNoCache.TotalMilliseconds))
        DockerCached = [int]([Math]::Round($timeDockerCached.TotalMilliseconds))
        BuildkitCached = [int]([Math]::Round($timeBuildkitCached.TotalMilliseconds))
    }
}

if (-not [string]::IsNullOrEmpty($TestDir)) {
    $dir = Get-Item -Path .\dockerfiles\$TestDir
    $dockerfiles = @($dir)
} elseif(-not [string]::IsNullOrEmpty($Path)) {
    $dir = Get-Item -Path $Path
    $dockerfiles = @($dir)
} elseif (-not [string]::IsNullOrEmpty($DockerfilesDir)) {
    $dockerfiles = Get-ChildItem $DockerfilesDir
} else {
    $dockerfiles = Get-ChildItem .\dockerfiles
}

foreach ($dir in $dockerfiles) {
    if (-not $dir.Name.StartsWith("skip")) {
        $results += Run($dir)
    } else {
        Write-Host "==> Skipping $($dir.Name)"
    }
}

if (-not (Test-Path -Path "./out")) {
    New-Item -ItemType Directory -Path "./out" | Out-Null
}

Write-Host "Writing Results: $($results.Count) rows"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$results | Export-Csv -Path ".\out\build_results_$timestamp.csv"

$results | Format-Table -AutoSize
