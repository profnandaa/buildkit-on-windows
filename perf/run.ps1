# pull the base images from registry to
# avoid skew of the first pull time.
# however, buildkit has a better pull time.
$baseImageNS = "mcr.microsoft.com/windows/nanoserver:ltsc2022"
$baseImageSC = "mcr.microsoft.com/windows/servercore:ltsc2022"

docker pull $baseImageNS
docker pull $baseImageSC
ctr image pull $baseImageNS
ctr image pull $baseImageSC

$dockerfiles = Get-ChildItem .\dockerfiles

$dockerBuild = "docker build -t perftest-docker-{0} {1}"
$buildctlBuild = "buildctl build --frontend dockerfile.v0 --local context={1} --local dockerfile={1} --output type=image,name=docker.io/profnandaa/perftest-bk-{0},push=false"

$results = @()

foreach ($dir in $dockerfiles) {
    Write-Host "Running Test Case: $($dir.Name)"
    $dockerfileHash = Get-FileHash -Algorithm SHA256 "$($dir.FullName)\Dockerfile"
    $timeDockerNoCache = Measure-Command {  Invoke-Expression "$($dockerBuild -f $dir.Name, $dir.FullName) --no-cache" }
    $timeDockerCached = Measure-Command { Invoke-Expression ($dockerBuild -f $dir.Name, $dir.FullName) }
    
    $timeBuildkitNoCache = Measure-Command { Invoke-Expression "$($buildctlBuild -f $dir.Name, $dir.FullName) --no-cache" }
    $timeBuildkitCached = Measure-Command { Invoke-Expression ($buildctlBuild -f $dir.Name, $dir.FullName) }

    # store results
    $results += [PSCustomObject]@{
        TestCase = $dir.Name
        Hash = $dockerfileHash.Hash.ToLower().Substring(0,8)
        DockerNoCache = [int]([Math]::Round($timeDockerNoCache.TotalMilliseconds))
        DockerCached = [int]([Math]::Round($timeDockerCached.TotalMilliseconds))
        BuildkitNoCache = [int]([Math]::Round($timeBuildkitNoCache.TotalMilliseconds))
        BuildkitCached = [int]([Math]::Round($timeBuildkitCached.TotalMilliseconds))
    }
}

if (-not (Test-Path -Path "./out")) {
    New-Item -ItemType Directory -Path "./out" | Out-Null
}

Write-Host "Writing Results: $($dockerfiles.Length) rows"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$results | Export-Csv -Path ".\out\build_results_$timestamp.csv"

$results | Format-Table -AutoSize
