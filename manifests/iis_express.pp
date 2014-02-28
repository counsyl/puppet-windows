# == Class: windows::iis_express
#
# Installs IIS Express 8.0.
#
class windows::iis_express(
  $base_url = 'http://download.microsoft.com/download/1/6/3/163BBBDE-5523-416D-A293-EA0492020E4A/',
  $basename = "iisexpress_8_0_RTM_${::architecture}_en-US.msi",
  $package  = 'IIS 8.0 Express',
  $source   = undef,
  $path     = 'C:\Program Files\IIS Express\iisexpress.exe',
  $appcmd   = 'C:\Program Files\IIS Express\appcmd.exe',
) {
  # Constructing the $source_uri.
  if $source {
    $source_uri = $source
  } else {
    $source_uri = "${base_url}${basename}"
  }

  # If a non-UNC URL is used, download the MSI with sys::fetch.
  if $source_uri !~ /^[\\]+/ {
    include windows
    $iis_source = "${windows::installers}\\${basename}"
    sys::fetch { 'download-iis':
      destination => $iis_source,
      source      => $source_uri,
      before      => Package[$package],
    }
  } else {
    $iis_source = $source_uri
  }

  # Install IIS Express.
  package { $package:
    ensure => installed,
    source => $iis_source,
  }
}
