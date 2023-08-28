[![Scheduled Package Maintenance](https://github.com/srjennings/chocolatey-iis-compression/actions/workflows/update-package.yml/badge.svg)](https://github.com/srjennings/chocolatey-iis-compression/actions/workflows/update-package.yml)

# IIS-Compression Chocolatey Package

# Installation

Install the Chocolatey package.
```powershell
choco install iis-compression
```

# Usage
Enable compression in IIS:
```
<configuration>
   <system.webServer>
      <urlCompression doStaticCompression="true" doDynamicCompression="true" />
   </system.webServer>
</configuration>
```

# Support

* For issues with the Chocolatey package, open issues in this repository.

* For issues with IIS Compression itself, reach out to [Microsoft](https://microsoft.com) support.

# License
[IIS Compression is licensed under MIT](https://github.com/microsoft/IIS.Compression/blob/main/LICENSE).

This Chocolatey package is licensed under [MIT](LICENSE).