param(
	[Parameter(Position = 0)]
	[int]$Count = 50,
	[Parameter(Position = 1)]
	[int]$Pause = 3
)

$dockerfile = @"
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 AS build
RUN mkdir out\sub && mklink /D sub out\sub && mklink /D sub2 out\sub && echo data> sub\foo 

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022
COPY --from=build /sub/foo .
COPY --from=build /sub2/foo bar
"@

if (-not (Test-Path -Path ".\Dockerfile")) {
	Set-Content -Path .\Dockerfile -Value $dockerfile
}

$cmd = "buildctl build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=docker.io/profnandaa/repro-5807,push=false --progress plain --no-cache"

for ($i = 1; $i -le $Count; $i++) { 
	Write-Host "`n=== Run $i`n"
	iex $cmd
	sleep $Pause
}

