
$ModulePath = $PSScriptRoot.Replace('\tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
$NewModulePath = $OriginalModulePath.Replace(";$ModulePath", "")
$NewModulePath += ";$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)
Write-Host $NewModulePath

Publish-Module -Name SimpleRequest -NuGetApiKey yourkey

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)