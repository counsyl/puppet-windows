# == Class: windows::autologon
#
# Enable automatic logon on Windows machine.
#
class windows::autologon(
  $ensure   = 'enabled',
  $username = undef,
  $password = undef,
  $domain   = undef,
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
        data   => '1',
      }

      registry_value { "${key}\\DefaultUsername":
        ensure => present,
        data   => $username,
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

      registry_value {
        ["${key}\\DefaultUsername", "${key}\\DefaultPassword",
         "${key}\\DefaultDomainName", "${key}\\ForceAutoLogon"]:
           ensure => absent,
      }
    }
    default: {
      fail("Invalid ensure value for windows::autologon.\n")
    }
  }
}
