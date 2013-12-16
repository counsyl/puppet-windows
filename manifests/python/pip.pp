# == Class: windows::python::pip
#
# Installs pip on windows.
#
class windows::python::pip {
  include windows::python::setuptools

  exec { 'windows-pip':
    command => "${windows::python::scripts}\\easy_install.exe pip",
    creates => "${windows::python::scripts}\\pip.exe",
    require => Class['windows::python::setuptools'],
  }
}
