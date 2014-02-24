# == Define: windows::path
#
# Ensures the given directory (specified by the resource name or `path` parameter)
# is a part of the Windows System %PATH%.
#
# == Parameters
#
# [*directory*]
#  The directory to add the Windows PATH, defaults to the name of the resource.
#
# [*target*]
#  The location where the PATH variable is stored, must be either 'Machine'
#  (the default) or 'User'.
#
define windows::path(
  $ensure    = 'present',
  $directory = $name,
  $target    = 'Machine',
) {
  # Ensure only valid parameters.
  validate_absolute_path($directory)
  validate_re($ensure, '^(present|absent)$', 'Invalid ensure parameter')
  validate_re($target, '^(Machine|User)$', 'Invalid target parameter')

  # Set the PATH environment variable, and refresh the environment.
  include windows::refresh_environment
  exec { "windows-path-${name}":
    command  => template('windows/path_set.ps1.erb'),
    unless   => template('windows/path_check.ps1.erb'),
    provider => 'powershell',
    notify   => Class['windows::refresh_environment'],
  }
}
