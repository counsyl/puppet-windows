# == Define: windows::environment
#
# Creates a Windows environment variable.
#
# === Parameters
#
# [*value*]
#  The value that the environment variable should be.
#
# [*ensure*]
#  The ensure value for the resource, must be 'present' or 'absent'.
#  Defaults to 'present'.
#
# [*variable*]
#  The environment variable to set, defaults to the name.
#
# [*target*]
#  The location where an environment variable is stored, must be either
#  'Machine', 'Process', or 'User'.  Defaults to 'Machine'.
#
define windows::environment(
  $value,
  $ensure   = 'present',
  $variable = $name,
  $target   = 'Machine',
) {

  # Ensure only valid target parameter.
  validate_re($target, '^(Machine|Process|User)$', 'Invalid target parameter')

  case $ensure {
    'present': {
      $command = "[Environment]::SetEnvironmentVariable('${variable}', '${value}', '${target}')"
      $unless = "if ([Environment]::GetEnvironmentVariable('${variable}', '${target}') -ne '${value}'){ exit 1 }"
    }
    'absent': {
      $command = "[Environment]::SetEnvironmentVariable('${variable}', \$null, '${target}')"
      $onlyif = "if ([Environment]::GetEnvironmentVariable('${variable}', '${target}') -ne \$null){ exit 1 }"
    }
    default: {
      fail("Invalid windows::environment ensure value.\n")
    }
  }

  # Execute the command that sets or unsets the environment variable, and
  # refresh the environment.
  include windows::refresh_environment
  exec { "env-${name}-${target}":
    command  => $command,
    unless   => $unless,
    onlyif   => $onlyif,
    provider => 'powershell',
    notify   => Class['windows::refresh_environment'],
  }
}
