# == Define: windows::unzip
#
# Extracts a ZIP archive on a Windows system.
#
# === Parameters
#
# [*name*]
#  The path to the ZIP file to extract.
#
# [*destination*]
#  Required, the destination directory to extract the files into.
#
# [*creates*]
#  A file that should exist after the ZIP file is extracted.
#
define windows::unzip(
  $destination,
  $creates,
) {
  # Setting $zipfile parameter
  $zipfile = $name
  exec { "unzip-${name}":
    command  => template('windows/unzip.ps1.erb'),
    creates  => $creates,
    provider => 'powershell',
  }
}
