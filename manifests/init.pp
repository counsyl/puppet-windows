# == Class: windows
#
# Creates resources used by other Windows manifests, e.g., the location to
# place downloaded installers.
#
class windows(
  $installers = 'C:\ProgramData\installers',
  $system32   = 'C:\WINDOWS\system32',
){
  if $::osfamily != 'windows' {
    fail("The windows module is only supported on Microsoft Windows.\n")
  }

  # Location of commonly-used programs from system32.
  $certutil = "${system32}\\certutil.exe"
  $cmd = "${system32}\\cmd.exe"
  $regsvr32 = "${system32}\\regsvr32.exe"

  # Ensure directory to store installers exists.
  file { $installers:
    ensure => directory,
  }
}
