# == Class: windows::update
#
# Configures settings for automatic Windows Updates.
#
# === Parameters
# For more information on these parameters, consult:
#  http://technet.microsoft.com/en-us/library/cc708449%28v=ws.10%29.aspx
#
# [*ensure*]
#  Defaults to 'enabled', if set to 'disabled' or 'absent' automatic
#  windows updates are disabled.
#
# [*options*]
#  How windows updates are installed, defaults to '2':
#
#   2 => Notify before download or installation.
#   3 => Automatically download and notify of installation.
#   4 => Automatic download and scheduled installation.
#   5 => Automatic Updates is required, but end users can configure it.
#
# [*detection_frequency*]
#  Time between detection cycles, in hours (1-22).  Default is undefined.
#
# [*day*]
#  Scheduled install day, 1-7 (Sunday-Monday), or 0 for every day.
#  Defaults to 0 (every day).  Only valid if options parameter is 4.
#
# [*time*]
#  Scheduled install time, 0-23 corresponding to hour (in 24-hour format).
#  Defaults to 3 (3:00AM).  Only valid if options parameter is 4.
#
# [*reboot_required*]
#  Whether any logged-on users get to choose whether or not to restart
#  their computer, defaults to true.
#
# [*reboot_warning_time*]
#  Length, in minutes, of the restart warning countdown after installing
#  updates with a deadline or scheduled updates.  Default is undefined.
#
# [*reschedule_wait_time*]
#  Time, in minutes, that Automatic Updates should wait at startup before
#  applying updates from a missed scheduled installation time.  Default
#  is undefinded.
#
# [*server*]
#  WSUS server to use, default is undefined.
#
# [*status_server*]
#  WSUS Status server to use, defaults to value of `server` parameter.
#
# [*key*]
#  Registry key for WindowsUpdate settings, defaults to:
#  'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
#
class windows::update(
  $ensure               = 'enabled',
  $options              = '2',
  $detection_frequency  = undef,
  $day                  = '0',
  $time                 = '3',
  $reboot_required      = true,
  $reboot_relaunch_time = undef,
  $reboot_warning_time  = undef,
  $reschedule_wait_time = undef,
  $server               = undef,
  $status_server        = undef,
  $key                  = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate',
  $service              = 'wuauserv',
) {
  validate_re($ensure, '^(enabled|present|disabled|absent)$')
  validate_re($options, '^[2-5]$')
  validate_re($day, '^[0-7]$')
  validate_re($time, '^[0-23]$')
  validate_bool($reboot_required)

  # Windows update service.
  service { $service:
    ensure => 'running',
    enable => true,
  }

  # Have any `registry_value` resources here refresh Windows Update service.
  Registry_value {
    notify => Service[$service],
  }

  # AutoUpdate settings registry key, ensure it and it's parent
  # are present.
  $au_key = "${key}\\AU"
  registry_key { [$key, $au_key]:
    ensure => present,
  }

  # Do we want to set a custom WSUS server?
  if is_string($server) {
    validate_re($server, '^http(s)?')

    registry_value { "${key}\\WUServer":
      ensure => present,
      type   => 'string',
      data   => $server,
    }

    if is_string($status_server) {
      validate_re($status_server, '^http(s)?')
      $status_server_data = $status_server
    } else {
      $status_server_data = $server
    }

    registry_value { "${key}\\WUStatusServer":
      ensure => present,
      type   => 'string',
      data   => $status_server_data,
    }

    registry_value { "${au_key}\\UseWUSServer":
      ensure  => present,
      type    => 'string',
      data    => 1,
    }
  } else {
    registry_value { ["${key}\\WUServer",
                      "${key}\\WUStatusServer",
                      "${au_key}\\UseWUServer"]:
      ensure => absent,
    }
  }

  # Whether Windows Update is enabled.
  if $ensure in ['enabled', 'present'] {
    $noautoupdate = 1
    $auoptions = $options
  } else {
    $noautoupdate = 0
    $auoptions = 1
  }

  registry_value { "${au_key}\\NoAutoUpdate":
    ensure => present,
    type   => 'dword',
    data   => $noautoupdate,
  }

  registry_value { "${au_key}\\AUOptions":
    ensure => present,
    type   => 'dword',
    data   => $auoptions,
  }

  if $options == '4' {
    registry_value { "${au_key}\\ScheduledInstallDay":
      ensure => present,
      type   => 'dword',
      data   => $day,
    }

    registry_value { "${au_key}\\ScheduledInstallTime":
      ensure => present,
      type   => 'dword',
      data   => $time,
    }
  } else {
    registry_value { ["${au_key}\\ScheduledInstallDay",
                      "${au_key}\\ScheduledInstallTime"]:
      ensure => absent,
    }
  }

  if $reboot_required {
    # Automatic Updates notifies user computer will restart in 5 minutes.
    $reboot_data = 0
  } else {
    # Logged-on user gets to choose whether or not to restart their computer.
    $reboot_data = 1
  }

  registry_value { "${au_key}\\NoAutoRebootWithLoggedOnUsers":
    ensure => present,
    type   => 'dword',
    data   => $reboot_data,
  }

  # Detection frequency.
  if is_string($detection_frequency) {
    registry_value { "${au_key}\\DetectionFrequencyEnabled":
      ensure => present,
      type   => 'dword',
      data   => 1,
    }

    registry_value { "${au_key}\\DetectionFrequency":
      ensure => present,
      type   => 'dword',
      data   => $detection_frequency,
    }
  } else {
    registry_value { "${au_key}\\DetectionFrequencyEnabled":
      ensure => present,
      type   => 'dword',
      data   => 0,
    }

    registry_value { "${au_key}\\DetectionFrequency":
      ensure => absent,
    }
  }

  # Reboot relaunch timeout.
  if is_string($reboot_relaunch_time) {
    registry_value { "${au_key}\\RebootRelaunchTimeoutEnabled":
      ensure => present,
      type   => 'dword',
      data   => 1,
    }

    registry_value { "${au_key}\\RebootRelaunchTimeout":
      ensure => present,
      type   => 'dword',
      data   => $reboot_relaunch_time,
    }
  } else {
    registry_value { "${au_key}\\RebootRelaunchTimeoutEnabled":
      ensure => present,
      type   => 'dword',
      data   => 0,
    }

    registry_value { "${au_key}\\RebootRelaunchTimeout":
      ensure => absent,
    }
  }

  # Reboot warning timeout.
  if is_string($reboot_warning_time) {
    registry_value { "${au_key}\\RebootWarningTimeoutEnabled":
      ensure => present,
      type   => 'dword',
      data   => 1,
    }

    registry_value { "${au_key}\\RebootWarningTimeout":
      ensure => present,
      type   => 'dword',
      data   => $reboot_warning_time,
    }
  } else {
    registry_value { "${au_key}\\RebootWarningTimeoutEnabled":
      ensure => present,
      type   => 'dword',
      data   => 0,
    }

    registry_value { "${au_key}\\RebootWarningTimeout":
      ensure => absent,
    }
  }

  # Reschedule wait time.
  if is_string($reschedule_wait_time) {
    registry_value { "${au_key}\\RescheduleWaitTimeEnabled":
      ensure => present,
      type   => 'dword',
      data   => 1,
    }

    registry_value { "${au_key}\\RescheduleWaitTime":
      ensure => present,
      type   => 'dword',
      data   => $reschedule_wait_time,
    }
  } else {
    registry_value { "${au_key}\\RescheduleWaitTimeEnabled":
      ensure => present,
      type   => 'dword',
      data   => 0,
    }

    registry_value { "${au_key}\\RescheduleWaitTime":
      ensure => absent,
    }
  }
}
