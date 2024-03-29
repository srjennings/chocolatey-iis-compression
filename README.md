[![Scheduled Package Maintenance](https://github.com/srjennings/chocolatey-iis-compression/actions/workflows/update-package.yml/badge.svg)](https://github.com/srjennings/chocolatey-iis-compression/actions/workflows/update-package.yml)

[![Chocolatey](https://img.shields.io/chocolatey/v/iis-compression.svg)](https://chocolatey.org/packages/iis-compression)

# IIS-Compression Chocolatey Package

# Installation

1. Stop the `WAS` and `W3SVC` services by entering the following:
```powershell
net stop was /y
```

2. Install the Chocolatey package.
```powershell
choco install iis-compression
```

3. Start the `WAS` and `W3SVC` services by entering the following:
```powershell
net start w3svc
```

The IIS Compression installer drops *iisbrotli.dll* and *iiszlib.dll* to `%ProgramFiles%\IIS\IIS Compression`. The installer registers `iisbrotli.dll` as the **br** (Brotli) compression scheme provider in **applicationHost.config**. It also replaces the default **gzip** compression scheme provider *gzip.dll* with *iiszlib.dll*. A sample `<httpCompression>` element in **applicationHost.config** is shown below:

```xml
<httpCompression directory="%SystemDrive%\inetpub\temp\IIS Temporary Compressed Files">
    <scheme name="br" dll="%ProgramFiles%\IIS\IIS Compression\iisbrotli.dll" />
    <scheme name="gzip" dll="%ProgramFiles%\IIS\IIS Compression\iiszlib.dll" />
    <dynamicTypes>
        <add mimeType="text/*" enabled="true" />
        <add mimeType="message/*" enabled="true" />
        <add mimeType="application/x-javascript" enabled="true" />
        <add mimeType="application/javascript" enabled="true" />
        <add mimeType="*/*" enabled="false" />
    </dynamicTypes>
    <staticTypes>
        <add mimeType="text/*" enabled="true" />
        <add mimeType="message/*" enabled="true" />
        <add mimeType="application/javascript" enabled="true" />
        <add mimeType="application/atom+xml" enabled="true" />
        <add mimeType="application/xaml+xml" enabled="true" />
        <add mimeType="image/svg+xml" enabled="true" />
        <add mimeType="*/*" enabled="false" />
    </staticTypes>
</httpCompression>
```

# Support

* For issues with the Chocolatey package, open issues in this repository.

* For issues with IIS Compression itself, reach out to [Microsoft](https://microsoft.com) support.

# License
[IIS Compression is licensed under MIT](https://github.com/microsoft/IIS.Compression/blob/main/LICENSE).

This Chocolatey package is licensed under [MIT](LICENSE).