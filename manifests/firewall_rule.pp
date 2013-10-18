# == Define: windows::firewall_rule
#
# Creates a Windows firewall rule.
#
# == Parameters
#
# [*ensure*]
#  Defaults to 'present', set to 'absent' to ensure the firewall rule is
#  deleted.
#
# [*program*]
#  Path to the program to allow through the firewall; either this or the
#  `localport` parameter is required.
#
# [*localport*]
#  The localport to open up through the firewall, if provided the `protocol`
#  parameter must also be specified.
#
define windows::firewall_rule(
  $ensure      = 'present',
  $program     = undef,
  $localport   = undef,
  $description = undef,
  $remoteport  = undef,
  $remoteip    = undef,
  $dir         = 'in',
  $action      = 'allow',
  $enable      = 'yes',
  $protocol    = undef,
  $profile     = undef,
) {

  # Make sure there's at least a program or a localport specified.
  if (! $program and ! $localport) {
    fail("Must provide either a program or localport for the Windows firewall rule.\n")
  }

  if ( $localport and ! $protocol) {
    fail("Must provide a protocol when specifying a localport Windows firewall rule.\n")
  }

  # Location of netsh executable and the condition command (which only checks if
  # the rule exists at this point).  The condition command will be used for
  # with `onlyif` or `unless`, depending on the ensure value.
  $netsh = 'C:\WINDOWS\system32\netsh.exe'
  $condition = "${netsh} advfirewall firewall show rule name=\"${name}\""

  case $ensure {
    'present': {
      # The command is constructed from template, which sets the proper
      # parameters for the `netsh advfirewall firewall add rule` command.
      exec { "windows-firewall-${name}":
        command => template('windows/firewall_rule.erb'),
        unless  => $condition,
      }
    }
    'absent': {
      exec { "windows-firewall-${name}":
        command => "${netsh} advfirewall firewall delete rule name=\"${name}\"",
        onlyif  => $condition,
      }
    }
    default: {
      fail("Invalid ensure value for `windows::firewall_rule` must be 'present' or 'absent'.\n")
    }
  }
}
