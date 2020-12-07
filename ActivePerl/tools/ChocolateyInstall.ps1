$packageName = 'ActivePerl'
$fileType = 'msi'
$binRoot = "$env:systemdrive\"


### Using an environment variable to to define the bin root until we implement YAML configuration ###
if($env:chocolatey_bin_root -ne $null){$binRoot = join-path $env:systemdrive $env:chocolatey_bin_root}
$silentArgs = "/quiet TARGETDIR=`"$binRoot`" PERL_PATH=Yes PERL_EXT=Yes"

$url64bit = 'https://cli-msi.s3.amazonaws.com/ActivePerl-5.28.msi'
$checksum64 = '552e3d4cf6068aa3751a4531c689e7045aa91d3e06bf6d731c55ef529723ee0a'
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

