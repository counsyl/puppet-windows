# == Class: windows::nssm
#
# Installs NSSM: the Non-Sucking Service Manager.
#
# === Parameters
#
# [*version*]
#  The version of NSSM to install, defaults to '2.16'.
#
# [*base_url*]
#  The base URL to download the NSSM ZIP file from, defaults to:
#  'http://nssm.cc/download/'.  Must have a trailing slash.
#
# [*destination*]
#  The root folder where the NSSM ZIP file is extracted to, defaults
#  to 'C:\Program Files'.
#
class windows::nssm(
  $version     = '2.16',
  $base_url    = 'http://nssm.cc/download/',
  $destination = 'C:\Program Files'
) {
  include windows
  $basename = "nssm-${version}.zip"
  $nssm_url = "${base_url}${basename}"
  $nssm_zip = "${windows::installers}\\${basename}"

  sys::fetch { 'download-nssm':
    source      => $nssm_url,
    destination => $nssm_zip,
  }

  # The root location of NSSM.
  $root = "${destination}\\nssm-${version}"
  windows::unzip { $nssm_zip:
    destination => 'C:\Program Files',
    creates     => $root,
    require     => Sys::Fetch['download-nssm'],
  }
}
