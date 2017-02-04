$packageName = 'ActivePerl'
$fileType = 'exe'
$binRoot = "$env:systemdrive\"


### Using an environment variable to to define the bin root until we implement YAML configuration ###
if($env:chocolatey_bin_root -ne $null){$binRoot = join-path $env:systemdrive $env:chocolatey_bin_root}
$silentArgs = "/quiet TARGETDIR=`"$binRoot`" PERL_PATH=Yes PERL_EXT=Yes"

$url = 'http://downloads.activestate.com/ActivePerl/releases/5.24.1.2402/ActivePerl-5.24.1.2402-MSWin32-x86-64int-401627.exe'
$checksum = 'efb8cf062bd8cf9f62e8cd18353c16a339300b8c17f04e7ed274419f9aa97dba'

$url64bit = 'http://downloads.activestate.com/ActivePerl/releases/5.24.1.2402/ActivePerl-5.24.1.2402-MSWin32-x64-401627.exe'
$checksum64 = '0df8e3d6dcac863a928e2bb18dbc6c2cead30bd1ced82e35b480cfd36e908ffb'

$checksumType = 'sha256'

Install-ChocolateyPackage `
    -PackageName $packageName -FileType $fileType -SilentArgs $silentArgs `
    -Url $url -Url64bit $url64bit -Checksum $checksum -Checksum64 $checksum64 -ChecksumType $checksumType

$toolsPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$parentPath = join-path $toolsPath '..'
$infFile = join-path $toolsPath 'PerlScriptIcon.inf'

# Update the inf file with the content path
Get-Content $infFile | Foreach-Object{$_ -replace "CONTENT_PATH", "$toolsPath"} | Set-Content 'TempFile.txt'
move-item 'TempFile.txt' $infFile -Force

# install the inf file
& rundll32 syssetup,SetupInfObjectInstallAction DefaultInstall 128 $infFile

