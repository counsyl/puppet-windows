# == Class: windows::java
#
# Downloads and installs Java Runtime Environment.
#
class windows::java(
  $version  = '7',
  $update   = '40',
  $build    = '43',
  $base_url = 'http://download.oracle.com/otn-pub/java/jdk/',
  $arch     = $::architecture,
  $referrer = 'http://edelivery.oracle.com',
) {
  include windows

  $jre_basename = "jre-${version}u${update}-windows-${arch}.exe"
  $jre_installer = "${windows::installers}\\${jre_basename}"
  $jre_url = "${base_url}${version}u${update}-b${build}/${jre_basename}"
  $cookie = "oraclelicensejre-${version}-oth-JPR=accept-securebackup-cookie;gpw_e24=${referrer}"

  exec { 'download-java':
    command  => template('windows/download_java.ps1.erb'),
    creates  => $jre_installer,
    provider => 'powershell',
    require  => Class['windows'],
  }

  if $arch == 'x64' {
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
