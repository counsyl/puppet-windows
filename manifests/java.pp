# == Class: windows::java
#
# Downloads and installs the Java Runtime Environment.
#
class windows::java(
  $version  = '7',
  $update   = '51',
  $build    = '13',
  $base_url = 'http://download.oracle.com/otn-pub/java/jdk/',
  $arch     = undef,
  $referrer = 'http://edelivery.oracle.com',
) {
  include windows

  # If user passed in architecture parameter, use it for `$java_arch`,
  # otherwise use i586 (for x86 systems).
  if $arch {
    $java_arch = $arch
  } else {
    case $::architecture {
      'x64': {
        $java_arch = 'x64'
      }
      'x86': {
        $java_arch = 'i586'
      }
      default: {
        fail("Unknown architecture for JRE: ${::architecture}")
      }
    }
  }

  # Determining Java's path depending on the version.
  case $version {
    '6': {
      $path = "C:\\Program Files\\Java\\jre1.6.0_${update}\\bin"
    }
    '7': {
      $path = 'C:\Program Files\Java\jre7\bin'
    }
    default: {
      fail("Do not know how to install Java version: ${version}.\n")
    }
  }

  # Setting up variables for downloading the JRE.
  $jre_basename = "jre-${version}u${update}-windows-${java_arch}.exe"
  $jre_installer = "${windows::installers}\\${jre_basename}"
  $jre_url = "${base_url}${version}u${update}-b${build}/${jre_basename}"
  $cookie = "oraclelicensejre-${version}-oth-JPR=accept-securebackup-cookie;gpw_e24=${referrer}"

  # Download the JRE using a PowerShell script that sets the license accepted cookie.
  exec { 'download-java':
    command  => template('windows/download_java.ps1.erb'),
    creates  => $jre_installer,
    provider => 'powershell',
    require  => Class['windows'],
  }

  # Determining the Java package name.
  if $java_arch == 'x64' {
    $java_package = "Java ${version} Update ${update} (64-bit)"
  } else {
    $java_package = "Java ${version} Update ${update}"
  }

  package { $java_package:
    ensure          => installed,
    source          => $jre_installer,
    install_options => ['/s'],
    require         => Exec['download-java'],
  }
}
