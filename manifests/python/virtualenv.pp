# == Class: windows::python::virtualenv
#
# Installs virtualenv on windows.
#
class windows::python::virtualenv {
  include windows::python::pip

  exec { 'windows-virtualenv':
    command => "${windows::python::scripts}\\pip.exe install virtualenv",
    creates => "${windows::python::scripts}\\virtualenv.exe",
    require => Class['windows::python::pip'],
  }
}
