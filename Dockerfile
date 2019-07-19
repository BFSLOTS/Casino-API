FROM microsoft/iis as base

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Setup one or more individual labels
LABEL com.i-m-code.aspnet-core-sample.version="1.0" \
	  com.i-m-code.aspnet-core-sample.release-date="17-07-2019" \
	  com.i-m-code.aspnet-core-sample.repo="derivco-test" \
	  com.i-m-code.aspnet-core-sample.targetoperatingsystem="windows"

# Install dotnet 2.2
ADD https://download.visualstudio.microsoft.com/download/pr/48adfc75-bce7-4621-ae7a-5f3c4cf4fc1f/9a8e07173697581a6ada4bf04c845a05/dotnet-hosting-2.2.0-win.exe "C:/setup/dotnet-hosting-2.2.0-win.exe"
RUN start-process -Filepath "C:/setup/dotnet-hosting-2.2.0-win.exe" -ArgumentList @('/install', '/quiet', '/norestart') -Wait 
RUN Remove-Item -Force "C:/setup/dotnet-hosting-2.2.0-win.exe"

# Install and start Microsoft IIS
RUN dism /online /enable-feature /all /featurename:iis-webserver /NoRestart

#Install WebDeploy
RUN Invoke-WebRequest -UseBasicParsing https://chocolatey.org/install.ps1 | Invoke-Expression; \
	choco install -y webdeploy; 

# Build and Publish with .Net Core SDK
FROM microsoft/dotnet:2.2-sdk AS build

WORKDIR \webapplication

ADD CassinoWebApi . 
 
# Restore and Build with Core SDK
RUN dotnet restore "C:/webapplication/CasinoWebApi.csproj"
RUN dotnet build "C:/webapplication/CasinoWebApi.csproj" --no-restore --no-dependencies -c Release -o /app 

FROM build AS publish

# Publish CasinoWebApi
RUN dotnet publish "C:/webapplication/CasinoWebApi.csproj" -c Release -o /publish

FROM base AS final

WORKDIR /inetpub/wwwroot/CasinoWebApi

# Create Web Site and Web Application
RUN Import-Module WebAdministration; \
    Remove-Website -Name 'Default Web Site'; \
    New-WebAppPool -Name 'CasinoWebApi'; \
    Set-ItemProperty IIS:\AppPools\CasinoWebApi -Name managedRuntimeVersion -Value ''; \
    Set-ItemProperty IIS:\AppPools\CasinoWebApi -Name enable32BitAppOnWin64 -Value 0; \
    Set-ItemProperty IIS:\AppPools\CasinoWebApi -Name processModel.identityType -Value Service; \
    New-Website -Name 'CasinoWebApi' \
                -Port 80 -PhysicalPath 'C:\inetpub\wwwroot\CasinoWebApi' \
                -ApplicationPool 'CasinoWebApi' -force
				
COPY --from=publish /publish .

# Make sure that Docker always uses default DNS servers which hosted by Dockerd.exe
RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord

HEALTHCHECK --interval=5s \
 CMD powershell -command \
    try { \
     $response = iwr http://localhost -UseBasicParsing; \
     if ($response.StatusCode -eq 200) { return 0} \
     else {return 1}; \
    } catch { return 1 }

EXPOSE 80
