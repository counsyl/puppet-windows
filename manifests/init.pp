# == Class: windows
#
# Creates resources used by other Windows manifests, e.g., the location to
# place downloaded installers.
#
# === Parameters
#
# [*installers*]
#  The directory where other manifests place their downloaded installation
#  files, defaults to 'C:\ProgramData\installers'.
#
class windows(
  $installers = "${windows::params::programdata}\\installers",
) inherits windows::params {
  # Ensure directory to store installers exists.
  file { $installers:
    ensure => directory,
  }

  # Location of commonly-used programs from system32.
  $certutil = "${windows::params::system32}\\certutil.exe"
  $cmd = "${windows::params::system32}\\cmd.exe"
  $regsvr32 = "${windows::params::system32}\\regsvr32.exe"
}
