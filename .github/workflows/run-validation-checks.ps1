<#
.SYNOPSIS
    Runs validation checks for the repository.

.DESCRIPTION
    This script performs validation checks such as verifying the existence and integrity of downloaded MSI files
    and checking if the version numbers have been updated.

#>

# Check if MSI files exist
$msiFiles = @("iiscompression_x86.msi", "iiscompression_amd64.msi")

foreach ($file in $msiFiles) {
    if (Test-Path $file) {
        Write-Host "$file exists."
    } else {
        Write-Host "$file does not exist."
        exit 1
    }
}

# Validate SHA256 hashes
$expectedHashes = @{
    "iiscompression_x86.msi" = $env:x86_sha256
    "iiscompression_amd64.msi" = $env:amd64_sha256
}

foreach ($file in $msiFiles) {
    $actualHash = (Get-FileHash -Path $file -Algorithm SHA256).Hash
    if ($actualHash -eq $expectedHashes[$file]) {
        Write-Host "SHA256 hash for $file matches."
    } else {
        Write-Host "SHA256 hash for $file does not match."
        exit 1
    }
}

# Check if version numbers have been updated
if ($env:x86_version -ne $env:nuspecVersion -or $env:amd64_version -ne $env:nuspecVersion) {
    Write-Host "Version numbers have been updated."
} else {
    Write-Host "Version numbers have not been updated."
    exit 1
}

# All checks passed
Write-Host "All validation checks passed."
