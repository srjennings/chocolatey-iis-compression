<#
.SYNOPSIS
    Updates the IIS Compression Chocolatey package with the latest version.

.DESCRIPTION
    This script downloads the latest IIS Compression MSI installers from the GitHub releases page, 
    calculates the SHA256 hash, extracts the version number, and updates the nuspec file.

    It is intended to be run as part of a GitHub workflow to keep the package up-to-date.

.LINK
    https://github.com/microsoft/IIS.Compression

#>

$response = Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/IIS.Compression/releases/latest'
$bodyContent = $response.body

$fileNameMatches = [regex]::Matches($bodyContent, '\|\s*(.*?)\s*\|\s*(.*?)\s*\|')
$urlMatches = [regex]::Matches($bodyContent, 'https://download\.microsoft\.com/download/[^\s]*\.msi')

$results = $fileNameMatches | ForEach-Object {
  [PSCustomObject]@{
    'File Name' = $_.Groups[1].Value
    'Sha256Sum' = $_.Groups[2].Value
  }
}

$msiInfo = $results | Group-Object 'File Name' -AsHashTable
$x86_msi, $x86_sha256 = $msiInfo['iiscompression_x86.msi'].'File Name', $msiInfo['iiscompression_x86.msi'].'Sha256Sum'
$amd64_msi, $amd64_sha256 = $msiInfo['iiscompression_amd64.msi'].'File Name', $msiInfo['iiscompression_amd64.msi'].'Sha256Sum'

# Update chocolateyinstall.ps1
Write-Host "Updating Chocolatey Install Script"

$urls = $urlMatches | ForEach-Object { $_.Value }
$x86_url = $urls -match 'iiscompression_x86\.msi'
$amd64_url = $urls -match 'iiscompression_amd64\.msi'

Invoke-WebRequest -Uri "$x86_url" -OutFile $x86_msi
Invoke-WebRequest -Uri "$amd64_url" -OutFile $amd64_msi

$x86_hash = (Get-FileHash -Path $x86_msi -Algorithm SHA256).Hash
$amd64_hash = (Get-FileHash -Path $amd64_msi -Algorithm SHA256).Hash

$content = Get-Content -Path "..\..\tools\chocolateyinstall.ps1"
$content = $content -replace 'url = .*', "url = '$x86_url'"
$content = $content -replace 'url64 = .*', "url64 = '$amd64_url'"
$content = $content -replace 'checksum = .*', "checksum = '$x86_hash'"
$content = $content -replace 'checksum64 = .*', "checksum64 = '$amd64_hash'"
Set-Content -Path "..\..\tools\chocolateyinstall.ps1" -Value $content

Write-Output "x86_msi=$x86_msi" >> $GITHUB_ENV
Write-Output "x86_sha256=$x86_sha256" >> $GITHUB_ENV
Write-Output "x64_msi=$amd64_msi" >> $GITHUB_ENV
Write-Output "amd64_sha256=$amd64_sha256" >> $GITHUB_ENV

$urls = $urlMatches | ForEach-Object { $_.Value }
$x86_url = $urls -match 'iiscompression_x86\.msi'
$amd64_url = $urls -match 'iiscompression_amd64\.msi'

Invoke-WebRequest -Uri "$x86_url" -OutFile $x86_msi
Invoke-WebRequest -Uri "$amd64_url" -OutFile $amd64_msi

function Get-MsiVersion {
  param ([string]$msiPath)
  $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
  $database = $windowsInstaller.OpenDatabase($msiPath, 0)
  $view = $database.OpenView("SELECT `Value` FROM `Property` WHERE `Property` = 'ProductVersion'")
  $view.Execute()
  $record = $view.Fetch()
  return $record.StringData(1)
}

$x86_hash = (Get-FileHash -Path $x86_msi -Algorithm SHA256).Hash
$amd64_hash = (Get-FileHash -Path $amd64_msi -Algorithm SHA256).Hash

Write-Output "Calculated x86 SHA256: $x86_hash"
Write-Output "Expected x86 SHA256: $x86_sha256"
Write-Output "Calculated amd64 SHA256: $amd64_hash"
Write-Output "Expected amd64 SHA256: $amd64_sha256"

# Check if hashes match
if ($x86_hash -eq $x86_sha256 -and $amd64_hash -eq $amd64_sha256) {
  Write-Output "Downloads are valid & Hashes match."
  
  # Get version from MSI
  $msiVersion = Get-MsiVersion -msiPath $x86_msi
  
  # Read nuspec file
  [xml]$nuspecContent = Get-Content -Path "..\..\iis-compression.nuspec"
  $nuspecVersion = $nuspecContent.package.metadata.version.Trim()

  
  # Output versions
  Write-Output "MSI Version: $msiVersion"
  Write-Output "Nuspec Version: $nuspecVersion"

  $msiVersion = $msiVersion -replace '(\d+)\.(\d+)\.0*(\d+)', '$1.$2.$3'
  Write-Output "Fixed version - $msiVersion"

  if ($msiVersion -eq $nuspecVersion) {

    Write-Output "MSI and nuspec versions match."
    $update = $false
  }
  else {
    Write-Output "MSI and nuspec versions do not match. Please update."
    $update = $true
  }

  if ($update -eq $true) {
    Write-Output "Updating nuspec file with new version $version"
    $nuspecContent.package.metadata.version = $version
    $nuspecContent.package.metadata.licenseUrl = $response.license.url
    $nuspecContent.package.metadata.projectUrl = $response.html_url
    $nuspecContent.package.metadata.requireLicenseAcceptance = $true
    $nuspecContent.Save("..\..\iis-compression.nuspec")
    Write-Output "Save completed."
    Write-Output "updated=$true" >> $GITHUB_ENV
  }
  elseif ($update -eq $false) {
    Write-Output "There is no need to update, exiting."
    Write-Output "updated=$false" >> $GITHUB_ENV
    exit 0
  }
}
else {
  Write-Output "Hashes do not match downloads. Please try downloading again."
  Write-Output "Exiting with failure code."
  exit 1
}

