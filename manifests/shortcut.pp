# == Define: windows::shortcut
#
# Creates a shortcut for the given path (should end in *.lnk) to the given
# target file.
#
define windows::shortcut(
  $target,
  $path              = $title,
  $arguments         = undef,
  $description       = undef,
  $icon_location     = undef,
  $working_directory = undef,
) {
  validate_re($path, '\.[lL][nN][kK]$')
  validate_absolute_path($path)
  validate_string($target)
  exec { "windows-shortcut-${path}":
    command  => template('windows/shortcut.ps1.erb'),
    creates  => $path,
    provider => 'powershell',
  }
}
