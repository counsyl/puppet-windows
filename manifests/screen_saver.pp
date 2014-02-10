# === Define: windows::screen_saver
#
# TODO. 
#
define windows::screen_saver(
  $user    = $name,
  $domain  = undef,
  $ensure  = 'present',
  $exe     = 'C:\Windows\system32\scrnsave.scr',
  $timeout = '300',
  $secure  = false,
) {
  exec { "screen-saver-${user}":
    command  => template('windows/screen_saver_set.ps1.erb'),
    unless   => template('windows/screen_saver_check.ps1.erb'),
    provider => 'powershell',
  }
}
