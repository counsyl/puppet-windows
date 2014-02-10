# === Define: windows::screen_saver
#
# TODO.
#
define windows::screen_saver(
  $ensure  = 'enabled',
  $user    = $name,
  $domain  = undef,
  $exe     = 'C:\Windows\system32\scrnsave.scr',
  $timeout = 300,
  $secure  = false,
) {
  validate_re($ensure, '^(present|enabled|absent|disabled)$')
  validate_string($user)
  validate_absolute_path($exe)
  validate_bool($secure)
  validate_re($timeout, '^\d+$')

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

  exec { "screen-saver-${user}":
    command  => template('windows/screen_saver_set.ps1.erb'),
    unless   => template('windows/screen_saver_check.ps1.erb'),
    provider => 'powershell',
  }
}
