# == Define: windows::unzip
#
# Extracts a ZIP archive on a Windows system.
#
# === Parameters
#
# [*destination*]
#  Required, the destination directory to extract the files into.
#
# [*creates*]
#  Required, a file that should exist after the ZIP file is extracted.
#
# [*zipfile*]
#  The path to the ZIP file to extract, defaults the $name of the resource.
#
define windows::unzip(
  $destination,
  $creates,
  $zipfile = $name,
) {
  exec { "unzip-${name}":
    command  => template('windows/unzip.ps1.erb'),
    creates  => $creates,
    provider => 'powershell',
  }
}
