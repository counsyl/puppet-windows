# == Class: windows::python::setuptools
#
# Installs Python's setuptools on Windows.
#
class windows::python::setuptools(
  $version  = '2.0.1',
  $base_url = 'https://pypi.python.org/packages/source/s/setuptools/',
) {
  include windows::python

  $ez_setup = "${windows::python::path}\\ez_setup.py"
  file { $ez_setup:
    ensure  => file,
    content => template('windows/ez_setup.py.erb'),
    require => Class['windows::python'],
  }
  
  exec { 'windows-setuptools':
    command => "${windows::python::path}\\python.exe ${ez_setup}",
    creates => "${windows::python::scripts}\\easy_install.exe",
    require => File[$ez_setup],
  }
}
