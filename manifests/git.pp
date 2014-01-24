# == Class: windows::git
#
# Installs Git for Windows.
#
class windows::git(
  $base_url = 'http://msysgit.googlecode.com/files/',
  $path     = 'C:\Program Files (x86)\Git\cmd',
  $source   = undef,
  $version  = '1.8.5.2-preview20131230',
) {
  # Basename of the installer.
  $basename = "Git-${version}.exe"

  # Name of the package resource the installer creates.
  $package = "Git version ${version}"

  # If a source URI is passed in, use it -- this can be a HTTP URL or UNC.
  if $source {
    $source_uri = $source
  } else {
    $source_uri = "${base_url}${basename}"
  }

  # If a non-UNC URL is used, download the Git setup with sys::fetch.
  if $source_uri !~ /^[\\]+/ {
    include windows
    $git_source = "${windows::installers}\\${basename}"

    sys::fetch { 'download-git':
      destination => $git_source,
      source      => $source_uri,
      before      => Package[$package],
    }
  } else {
    $git_source = $source_uri
  }

  # Install the Git package.
  package { $package:
    ensure          => installed,
    source          => $git_source,
    install_options => ['/VERYSILENT'],
  }

  # If `$path` is set, ensure that Git is a component of the %PATH%.
  if $path {
    windows::path { 'git-path':
      directory => $path,
      require   => Package[$package],
    }
  }
}
