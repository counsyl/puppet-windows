# == Class: windows::python
#
# Installs CPython on Windows.
#
# === Parameters
#
# TODO
#
class windows::python(
  $version   = '2.7.6',
  $arch      = $::architecture,
  $allusers  = true,
  $base_url  = undef,
  $source    = undef,
  $targetdir = undef,
  $win_path  = true,
) {
  # The basename of the MSI and the package's name depend on architecture.
  if $arch == 'x64' {
    $basename = "python-${version}.amd64.msi"
    $package = "Python ${version} (64-bit)"
  } else {
    $basename = "python-${version}.msi"
    $package = "Python ${version}"
  }

  # Determining where the MSI is coming from for the package resource.
  if $source {
    $source_uri = $source
  } else {
    if $base_url {
      $source_uri = "${base_url}${basename}"
    } else {
      $source_uri = "http://www.python.org/ftp/python/${version}/${basename}"
    }
  }

  # If a non-UNC URL is used, download the MSI with sys::fetch.
  if $source_uri !~ /^[\\]+/ {
    include windows
    $python_source = "${windows::installers}\\${basename}"

    sys::fetch { 'download-python':
      destination => $python_source,
      source      => $source_uri,
      before      => Package[$package],
    }
  } else {
    $python_source = $source_uri
  }

  if $allusers {
    $allusers_val = '1'
  } else {
    $allusers_val = '0'
  }

  # Determining Python's path.
  if $targetdir {
    $path = $targetdir
  } else {
    $path = inline_template(
      "<%= \"C:\\\\Python#{@version.split('.').join('')[0..1]}\" %>"
    )
  }

  # Where site-packages lives.
  $site_packages = "${path}\\Lib\\site-packages"

  # Install Python from the MSI.
  package { $package:
    ensure          => installed,
    source          => $python_source,
    install_options => [ { 'TARGETDIR' => $path,
                           'ALLUSERS'  => $allusers_val } ],
  }

  # If `$win_path` is set to true, ensure that Python is a component of
  # the Windows %PATH%.
  if $win_path {
    windows::path { 'python-path':
      directory => $path,
      require   => Package[$package],
    }
  }
}
