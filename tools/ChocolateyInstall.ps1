$packageName = 'ActivePerl'
$fileType = 'exe'
$binRoot = "$env:systemdrive\"


### Using an environment variable to to define the bin root until we implement YAML configuration ###
if($env:chocolatey_bin_root -ne $null){$binRoot = join-path $env:systemdrive $env:chocolatey_bin_root}
$silentArgs = "/quiet TARGETDIR=`"$binRoot`" PERL_PATH=Yes PERL_EXT=Yes"

$url64bit = 'http://downloads.activestate.com/ActivePerl/releases/5.24.3.2404/ActivePerl-5.24.3.2404-MSWin32-x64-404865.exe'
$checksum64 = 'cb093acd7e5462ec3450372c76e3f6096a4f6ca75f5c9770a96c9bcf7e35950d'

$checksumType = 'sha256'

Install-ChocolateyPackage `
    -PackageName $packageName -FileType $fileType -SilentArgs $silentArgs `
    -Url64bit $url64bit -Checksum64 $checksum64 -ChecksumType $checksumType

$toolsPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$parentPath = join-path $toolsPath '..'
$infFile = join-path $toolsPath 'PerlScriptIcon.inf'

# Update the inf file with the content path
Get-Content $infFile | Foreach-Object{$_ -replace "CONTENT_PATH", "$toolsPath"} | Set-Content 'TempFile.txt'
move-item 'TempFile.txt' $infFile -Force

# install the inf file
& rundll32 syssetup,SetupInfObjectInstallAction DefaultInstall 128 $infFile

