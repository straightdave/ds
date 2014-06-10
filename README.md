ds
==
## Description
  '__ds__' is a simple HTTP server written in pure PowerShell. The purpose of 'ds' is to host pages or simple Web application on the Windows machines without IIS and other heavy peripherals. Furthermore, 'ds' enables users to write [__EPS__](http://straightdave.github.io/eps) (PowerShell-embedded) HTML like erb or PHP files and render dynamic web pages with PowerShell.


## Core file list
 - ds.ps1 (tcp listener)
 - ds_lib.ps1 (req - resp parsing)
 - eps.ps1 (EPS lib)

## Usage:
Start server:
```powershell
PS> .\ds.ps1 [port]
```

Stop server:
just shut down the PowerShell session/window.

## Note
 - To solve the security warning when running scripts, try "set-executionpolicy bypass" which is easiest way.

## Contribute
Please feel free to test and bug reports are welcomed very much.
Author email: eyaswoo@163.com
