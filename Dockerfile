# escape=`

FROM microsoft/dotnet-framework:4.7.2-sdk AS build

LABEL maintaner="elano.melo@sti.ufc.br"

WORKDIR /cade

COPY codigo_fonte/*.sln .
COPY codigo_fonte/PGD.UI.Mvc/*.csproj ./PGD.UI.Mvc/
COPY codigo_fonte/PGD.UI.Mvc/*.config ./PGD.UI.Mvc/
COPY codigo_fonte/PGD.Application/*.csproj ./PGD.Application/
COPY codigo_fonte/PGD.Application/*.config ./PGD.Application/
COPY codigo_fonte/PGD.Domain/*.csproj ./PGD.Domain/
COPY codigo_fonte/PGD.Domain/*.config ./PGD.Domain/
COPY codigo_fonte/PGD.UpdateDatabase/*.csproj ./PGD.UpdateDatabase/
COPY codigo_fonte/PGD.UpdateDatabase/*.config ./PGD.UpdateDatabase/
COPY codigo_fonte/PGD.Infra.Data/*.csproj ./PGD.Infra.Data/
COPY codigo_fonte/PGD.Infra.Data/*.config ./PGD.Infra.Data/
COPY codigo_fonte/PGD.Infra.CrossCutting.IoC/*.csproj ./PGD.Infra.CrossCutting.IoC/
COPY codigo_fonte/PGD.Infra.CrossCutting.IoC/*.config ./PGD.Infra.CrossCutting.IoC/
COPY codigo_fonte/PGD.Infra.CrossCutting.Util/*.csproj ./PGD.Infra.CrossCutting.Util/
COPY codigo_fonte/PGD.Infra.CrossCutting.Util/*.config ./PGD.Infra.CrossCutting.Util/
RUN nuget restore
COPY codigo_fonte/ .

RUN msbuild PGD.UI.Mvc /p:Configuration=Release `
            /p:Platform=AnyCPU `
            /p:WebPublishMethod=FileSystem `
            /p:DeleteExistingFiles=True `
            /p:publishUrl=c:\cade-pdg `
            /t:WebPublish

FROM microsoft/aspnet:4.7.2 AS runtime
WORKDIR /inetpub/wwwroot/
COPY --from=build c:/cade-pdg/. ./
COPY --from=build /cade/packages/EntityFramework.6.1.3/tools/migrate.exe/ ./bin/
# COPY --from=build /cade/migrate.ps1/ ./
COPY --from=build /cade/entrypoint.ps1/ ./


RUN powershell -Command Import-Module WebAdministration; `
                Remove-Website -Name 'Default Web Site'; `
                New-WebAppPool -Name "pg_cade_pool"; `
                Set-ItemProperty -Path "IIS:\AppPools\pg_cade_pool" managedRuntimeVersion "v4.0"; `
                Set-ItemProperty -Path "IIS:\AppPools\pg_cade_pool" processModel.identityType "ApplicationPoolIdentity"; `
                Set-ItemProperty -Path "IIS:\AppPools\pg_cade_pool" managedPipelineMode "Integrated"; `
                Set-ItemProperty -Path "IIS:\AppPools\pg_cade_pool" enable32BitAppOnWin64 true; `
                New-WebSite -Name "pg-cade" -Port 80 -PhysicalPath "C:\inetpub\wwwroot" -ApplicationPool pg_cade_pool;

ENTRYPOINT ["powershell.exe","./entrypoint.ps1"]