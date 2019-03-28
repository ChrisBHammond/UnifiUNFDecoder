# UnifiUNFDecoder
This is some powershell script to partly decode UNF backup files. Still a work in progress.

Open Powershell ISE( Most copies of windows should have this installed )
You might have to set your set-executionpolicy see this link.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6

Open the UnifiUNFDecoder.ps1
Go to bottom and change this line to point to your UNF file
 $fullpath = "C:\temp\5.10.19-20190320-2118.unf"
 
 Run the powershell script from the green play button. 
 Open new file with 7-Zip.
