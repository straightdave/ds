ds
==

Dave's simple HTTP server written in PowerShell

Note: for higher performance please use ds-v2 which is a multi-thread edition. It saves 90% time per connection.

Core files:
 - ds.ps1 (tcp listener)
 - ds_lib.ps1 (req - resp parsing)

Sample files:
 - hello.html and sample.ps1 => testing POST
 - sample.ps2 => PowerShell-embedded HTML

Functions:
 - host normal static html pages (plus their assets like .js and .css)
 - host HTML-embedded PowerShell (.ps1) pages; actually any PowerShell file which can generate HTML code
 - host PowerShell-embedded HTML (.ps2) pages; its syntax is like PHP's. please refer to 'sample.ps2'

==

Usage:

 - To Start server:

`PS> .\ds.ps1 [port]`

 - To Stop server:

just shut down that PowerShell session/window.


Related Parameters:

1. port
   Default port is 8889. You can change it in ds.ps1
2. home dir
   Default is C:\dshome, you can change it in ds_lib.ps1
3. Customized 404 html page
   C:\dshome\404.html, you can DIY.

==

You can change everything because they are written with scripts

P.S.
 - to solve the security warning when running scripts, try "set-executionpolicy bypass" which is easiest way.
