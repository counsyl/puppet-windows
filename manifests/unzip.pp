# == Define: windows::unzip
#
# Extracts a ZIP archive on a Windows system.
#
# === Parameters
#
# [*destination*]
#  Required, the destination directory to extract the files into.
#
# [*creates*]
#  The `creates` parameter for the exec resource that extracts the ZIP file,
#  default is undefined.
#
# [*refreshonly*]
#  The `refreshonly` parameter for the exec resource that extracts the ZIP file,
#  defaults to false.
#
# [*unless*]
#  The `unless` parameter for the exec resource that extracts the ZIP file,
#  default is undefined.
#
# [*zipfile*]
#  The path to the ZIP file to extract, defaults the name of the resource.
#
# [*provider*]
#  Advanced parameter, sets the provider for the exec resource that extracts
#  the ZIP file, defaults to 'powershell'.
#
# [*options*]
#  Advanced parameter, sets the extraction options for the `Folder.CopyHere`
#  method:
#
#  http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866.
#
#  Defaults to 20, which is sum of:
#   * 4:  Do not display a progress dialog box.
#   * 16: Respond with "Yes to All" for any dialog box that is displayed.
#
# [*command_template*]
#  Advanced paramter for generating PowerShell that extracts the ZIP file,
#  defaults to 'windows/unzip.ps1.erb'.
#
# [*timeout*]
# Execution timeout in seconds for the unzip command; 0 disables timeout,
# defaults to 300 seconds (5 minutes).
#
define windows::unzip(
  $destination,
  $creates          = undef,
  $refreshonly      = false,
  $unless           = undef,
  $zipfile          = $name,
  $provider         = 'powershell',
  $options          = '20',
  $command_template = 'windows/unzip.ps1.erb',
  $timeout          = 300,
) {
  validate_absolute_path($destination)

  if (! $creates and ! $refreshonly and ! $unless){
    fail("Must set one of creates, refreshonly, or unless parameters.\n")
  }

  exec { "unzip-${name}":
    command     => template($command_template),
    creates     => $creates,
    refreshonly => $refreshonly,
    unless      => $unless,
    provider    => $provider,
    timeout     => $timeout,
  }
}
