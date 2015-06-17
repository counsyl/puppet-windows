# == Class: windows::params
#
# Parameters for Windows.  Has one parameter, `$system_root`, which may
# be used to account for when the Windows root drive is not 'C:\'.
#
class windows::params(
  $system_root = "C:\\",
) {
  if $::osfamily != 'windows' {
    fail('The windows module is only supported on Microsoft Windows.')
  }

  # Program Data
  $programdata = "${system_root}ProgramData"

  # Windows directory.
  $windir = "${system_root}Windows"

  # Windows system directory.
  $system32 = "${windir}\\system32"

  # Location of commonly-used programs from system32.
  $certutil = "${system32}\\certutil.exe"
  $cmd = "${system32}\\cmd.exe"
  $regsvr32 = "${system32}\\regsvr32.exe"
}
