# == Define: windows::screen_saver
#
# Sets up screen saver settings for the user of the given name.
#
# === Parameters
#
# [*ensure*]
#  Ensure value for this resource, defaults to 'present'.  Set to 'absent' or
#  'disabled' to disable the screen saver for the user.
#
# [*user*]
#  The user to set the screen saver for, defaults to the name of the resource.
#
# [*domain*]
#  Domain the user belongs, default is undefined.
#
# [*exe*]
#  The executable to use for the screen saver, defaults to:
#  'C:\Windows\system32\scrnsave.scr' (the blank screen saver).
#
# [*secure*]
#  Whether a password is required to unlock the screen saver, default is false.
#
# [*timeout*]
#  How long until the screen saver activates, may be specified as
#  seconds ('3600'), minutes ('60m'), or hours ('1h').  Default is
#  '300' (5 minutes).
#
define windows::screen_saver(
  $ensure  = 'present',
  $user    = $name,
  $domain  = undef,
  $exe     = 'C:\Windows\system32\scrnsave.scr',
  $secure  = false,
  $timeout = 300,
) {
  validate_re($ensure, '^(present|enabled|absent|disabled)$')
  validate_string($user)
  validate_absolute_path($exe)
  validate_bool($secure)
  validate_re($timeout, '^\d+[mMhH]?$')

  if $ensure in ['present', 'enabled'] {
    $active_value = 1
  } else {
    $active_value = 0
  }

  if $secure {
    $secure_value = 1
  } else {
    $secure_value = 0
  }

  if $timeout =~ /^(\d+)([MmHh])$/ {
    case $2 {
      'm': {
        $timeout_minutes = $1
        $timeout_seconds = inline_template('<%= Integer(@timeout_minutes) * 60 %>')
      }
      'h': {
        $timeout_hours = $1
        $timeout_seconds = inline_template('<%= Integer(@timeout_hours) * 3600) %>')
      }
      default: {
        fail('Unknown timeout format.')
      }
    }
  } else {
    $timeout_seconds = $timeout
  }

  exec { "screen-saver-${user}":
    command  => template('windows/screen_saver_set.ps1.erb'),
    unless   => template('windows/screen_saver_check.ps1.erb'),
    provider => 'powershell',
  }
}
