FROM mcr.microsoft.com/windows/servercore:ltsc2022

COPY ./ /
# install dependencies
RUN powershell -File .\install_deps.ps1
RUN powershell -File .\networking_setup.ps1

# start script dir, /start, mounted as a volume
# -v C:\play\buildkit\start:C:\start
ENTRYPOINT ["powershell", "-File", "C:/start/start.ps1"]
