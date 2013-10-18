# == Class: windows::refresh_env
#
# Refresh the Windows Environment.  Makes it possible to have updated
# Windows environment varialbes (e.g., the %Path%) without restarting
# or logging off and back on.
#
class windows::refresh_environment(
  $command_template = 'windows/refresh_environment.ps1.erb',
  $refreshonly      = true,
  $unless           = undef,
  $onlyif           = undef,
  $provider         = 'powershell',
){
  exec { 'windows-refresh-environemnt':
    command     => template($command_template),
    refreshonly => $refreshonly,
    unless      => $unless,
    onlyif      => $onlyif,
    provider    => $provider,
  }
}
