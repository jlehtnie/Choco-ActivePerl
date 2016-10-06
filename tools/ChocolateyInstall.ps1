$packageName = 'ActivePerl'
$fileType = 'exe'
$binRoot = "$env:systemdrive\"


### Using an environment variable to to define the bin root until we implement YAML configuration ###
if($env:chocolatey_bin_root -ne $null){$binRoot = join-path $env:systemdrive $env:chocolatey_bin_root}
$silentArgs = "/quiet TARGETDIR=`"$binRoot`" PERL_PATH=Yes PERL_EXT=Yes"

$url = 'http://downloads.activestate.com/ActivePerl/releases/5.24.0.2400/ActivePerl-5.24.0.2400-MSWin32-x86-64int-300560.exe'
$checksum = '2a13a4f3654f943d4ac725cfd18f72f750fb0f697b12a42b52551ef2d051cf3f'

$url64bit = 'http://downloads.activestate.com/ActivePerl/releases/5.24.0.2400/ActivePerl-5.24.0.2400-MSWin32-x64-300558.exe'
$checksum64 = '9e6ab2bb1335372cab06ef311cbaa18fe97c96f9dd3d5c8413bc864446489b92'

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

