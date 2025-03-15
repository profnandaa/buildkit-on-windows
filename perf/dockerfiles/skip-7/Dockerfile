FROM mcr.microsoft.com/windows/servercore:ltsc2022

ENV PATH "c:\\Windows\\System32;c:\\Windows;C:\\Windows\\System32\\WindowsPowerShell\\v1.0"

SHELL ["powershell", "-Command"]

WORKDIR C:\\app

ENV PYTHON_VERSION=3.11.6

ENV PATH "$PATH;C:\Python\Scripts\;C:\Python\;C:\Windows\System32\OpenSSH\;C:\Program Files\Git\cmd"

RUN Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$Env:PYTHON_VERSION/python-$Env:PYTHON_VERSION-amd64.exe" -OutFile "C:\\python-installer.exe" -UseBasicParsing; \
    $gitRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" -Headers @{ 'User-Agent' = 'Docker Build' }; \
    $gitInstallerUrl = $gitRelease.assets | Where-Object { $_.name -like '*64-bit.exe' } | Select-Object -ExpandProperty browser_download_url; \
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile "C:\\git-installer.exe" -UseBasicParsing;

RUN Start-Process -FilePath "C:\\python-installer.exe" -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1 TargetDir=C:\\Python' -Wait; \
    Start-Process -FilePath "C:\\git-installer.exe" -ArgumentList '/VERYSILENT /NORESTART /SP-' -Wait; \
    Remove-Item -Force "C:\\python-installer.exe", "C:\\git-installer.exe"; \
    if (!(Test-Path 'C:\\Python')) { throw 'Python installation failed!' }; \
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::Machine)

RUN $latestRelease = (Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/lisa/releases/latest").tag_name; \
    git clone --depth 1 --branch $latestRelease https://github.com/microsoft/lisa.git C:\\app\\lisa

WORKDIR /

RUN Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing; \
    Expand-Archive -Path 'AzCopy.zip' -DestinationPath 'AzCopy'; \
    $FullAzCopyPath = (Get-ChildItem -Path 'AzCopy' -Recurse -File -Filter 'azcopy.exe').FullName; \
    Write-Host "AzCopy path is ${FullAzCopyPath}"; \
    Move-Item -Path $FullAzCopyPath -Destination "C:\\azcopy.exe"; \
    Remove-Item -Path 'AzCopy.zip' -Force; \
    Remove-Item -Path 'AzCopy' -Recurse -Force

ENV LISA_azcopy_path="C:\\azcopy.exe"

WORKDIR C:\\app\\lisa

RUN python -m pip install --no-cache-dir --upgrade pip; \
    python -m pip install --no-cache-dir --editable .[ado,azure,libvirt,baremetal] --config-settings editable_mode=compat

# src: https://github.com/microsoft/lisa/blob/a0aeaf8c9b73c9666ab38eb0ff4760d48c362b78/Dockerfile.windows#L4