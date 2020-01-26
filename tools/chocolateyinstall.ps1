$ErrorActionPreference = 'Stop';

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_x86.msi'
$url64      = 'https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_amd64.msi'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  fileType      = 'MSI'
  url           = $url
  url64bit      = $url64

  softwareName  = 'iis-compression*'

  checksum      = '4a6bcef528bafb2bd2df031ac272dabb'
  checksum64    = '690010bd3f5a71ea3335e21af6e4aed4'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs