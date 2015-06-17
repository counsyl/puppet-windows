# == Class: windows::autologon
#
# Enable automatic logon to the Windows PC.
#
# === Parameters
#
# [*ensure*]
#  Ensure value, defaults to 'enabled'.  Set to 'absent' or 'disabled' to
#  disable automatic logon.
#
# [*user*]
#  Username to enable automatic logon for required when `ensure => 'enabled'`.
#
# [*password*]
#  Password to use for automatic logon, required if there's a password set
#  for the username.
#
# [*force*]
#  Sets the `ForceAutoLogon` key if set, defaults to false.
#
# [*key*]
#  Advanced parameter, should not need to change.  The base windows registry
#  key for automatic logon settings, defaults to:
#  'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
#
class windows::autologon(
  $ensure   = 'enabled',
  $user     = undef,
  $password = undef,
  $domain   = undef,
  $force    = false,
  $key      = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon',
) {
  case $ensure {
    'enabled', 'present': {
      if ! $user {
        fail("Must provide a user parameter for windows::autologon.\n")
      }

      registry_value { "${key}\\AutoAdminLogon":
        ensure => present,
        data   => '1',
      }

      registry_value { "${key}\\DefaultUsername":
        ensure => present,
        data   => $user,
      }

      if $password {
        registry_value { "${key}\\DefaultPassword":
          ensure => present,
          data   => $password,
        }
      }

      if $domain {
        registry_value { "${key}\\DefaultDomainName":
          ensure => present,
          data   => $domain,
        }
      }

      if $force {
        registry_value { "${key}\\ForceAutoLogon":
          ensure => present,
          data   => '1',
        }
      }
    }
    'disabled', 'absent': {
      registry_value { "${key}\\AutoAdminLogon":
        ensure => present,
        data   => '0',
      }

      registry_value { ["${key}\\DefaultUsername", "${key}\\DefaultPassword",
                        "${key}\\DefaultDomainName", "${key}\\ForceAutoLogon"]:
        ensure => absent,
      }
    }
    default: {
      fail("Invalid ensure value for windows::autologon.\n")
    }
  }
}
