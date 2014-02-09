# == Class: windows::autologon
#
# Enable automatic logon on Windows machine.
#
class windows::autologon(
  $ensure   = 'enabled',
  $username = undef,
  $password = undef,
  $force    = false,
  $key      = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon',
) {
  case $ensure {
    'enabled', 'present': {
      if ! $username {
        fail("Must provide a username parameter for windows::autologon.\n")
      }

      registry_value { "${key}\\AutoAdminLogon":
        ensure => present,
        value  => '1',
      }

      registry_value { "${key}\\DefaultUsername":
        ensure => present,
        value  => $username,
      }

      if $password {
        registry_value { "${key}\\DefaultPassword":
          ensure => present,
          value  => $password,
        }
      }

      if $force {
        registry_value { "${key}\\ForceAutoLogon":
          ensure => present,
          value  => '1',
        }
      }
    }
    'disabled', 'absent': {
      registry_value { "${key}\\AutoAdminLogon":
        ensure => present,
        value  => '0',
      }

      registry_value {
        ["${key}\\DefaultUsername", "${key}\\DefaultPassword",
         "${key}\\ForceAutoLogon"]:
           ensure => absent,
      }
    }
    default: {
      fail("Invalid ensure value for windows::autologon.\n")
    }
  }
}
