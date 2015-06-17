# == Class: windows::power_scheme
#
# Configures the power scheme used by Windows.
#
# === Parameters
#
# [*ensure*]
#  The power scheme to use, defaults to 'Balanced'.  Must correspond to a key in the
#  `$guids` parameter.
#
# [*guids*]
#  A mapping of power scheme names to their GUID.  The default schemes supported are:
#  'Balanced', 'High performance', and 'Power saver'.
#
class windows::power_scheme(
  $ensure = 'Balanced',
  $guids  = {
    'Balanced'         => '381b4222-f694-41f0-9685-ff5bb260df2e',
    'High performance' => '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c',
    'Power saver'      => 'a1841308-3541-4fab-bc81-f71556f20b4a',
  }
){
  validate_string($ensure)
  validate_hash($guids)

  # Get the GUID for the desired power scheme.
  if ! has_key($guids, $ensure) {
    fail('There is no GUID for the power scheme.')
  }
  $guid = $guids[$ensure]

  # Use POWERCFG.EXE to set the desired power scheme.
  exec { 'windows-powercfg':
    command  => "POWERCFG -SETACTIVE ${guid}",
    unless   => template('windows/powercfg_check.ps1.erb'),
    provider => 'powershell',
  }
}
