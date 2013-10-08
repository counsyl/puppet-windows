# == Class: windows
#
# Creates resources used by other Windows manifests, e.g., the location to
# place downloaded installers.
#
class windows(
  $installers = 'C:\ProgramData\installers',
){
  file { $installers:
    ensure => directory,
  }
}
