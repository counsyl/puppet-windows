# == Define: regsvr32
#
# Registers a DLL (or other control) specfied by the resources name as a
# component in the registry.
#
# === Parameters
#
# [*clsid*]
#  Required, the GUID(s) created in 'HKEY_CLASSES_ROOT\CLSID' when the DLL
#  is registered.  May be an array or a single string, and each GUID should
#  be enclosed in brackets, e.g., '{B125EE95-7C15-4FCA-8D78-1707DD4ECC81}'.
#
# [*dll*]
#  The path to the DLL to register, defaults to the resource name.
#
# [*wow64*]
#  Are the class GUID(s) located on the Windows 32-bit on Windows 64-bit
#  (WoW64) registry node.  Defaults to true on 64-bit systems, set to false
#  if the class GUID(s) are native 64-bit.
#
define windows::regsvr32(
  $clsid,
  $ensure = 'present',
  $dll    = $name,
  $wow64  = $::architecture == 'x64',
) {
  include windows

  # Calculating the HKEY_CLASSES_ROOT location, depending on whether we
  # are using WoW64 or not.
  if $wow64 {
    $hkcr = 'Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID'
  } else {
    $hkcr = 'Registry::HKEY_CLASSES_ROOT\CLSID'
  }

  case $ensure {
    'present': {
      $command = "${windows::regsvr32} \"${dll}\""
      $unless  = template('windows/regsvr32.ps1.erb')
    }
    'absent': {
      $command = "${windows::regsvr32} /u \"${dll}\""
      $onlyif  = template('windows/regsvr32.ps1.erb')
    }
    default: {
      fail("Invalid ensure value for windows::regsvr32.\n")
    }
  }

  exec { "regsvr32-${name}":
    command  => $command,
    unless   => $unless,
    onlyif   => $onlyif,
    provider => 'powershell',
  }
}
