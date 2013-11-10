# == Define: windows::environment
#
# Set Windows environment variable to the given value.
#
# === Parameters
#
# [*value*]
#  The value that the environment variable should be, required by default
#  (when ensure = 'present').
#
# [*ensure*]
#  The ensure value for the resource, must be 'present' or 'absent'.
#  Defaults to 'present'.  When set to 'absent', the environment variable
#  is removed.
#
# [*variable*]
#  The environment variable to set, defaults to the name of the resource.
#
# [*target*]
#  The location where an environment variable is stored, must be either
#  'Machine' (the default) or 'User'.
#
define windows::environment(
  $value    = undef,
  $ensure   = 'present',
  $variable = $name,
  $target   = 'Machine',
) {

  # Ensure only valid target parameter.
  validate_re($target, '^(Machine|User)$', 'Invalid target parameter')

  case $ensure {
    'present': {
      if (! $value) {
        fail("Must provide a value to set ${variable} with.\n")
      }
      $command = "[Environment]::SetEnvironmentVariable(\"${variable}\", \"${value}\", \"${target}\")"
      $unless = "if ([Environment]::GetEnvironmentVariable(\"${variable}\", \"${target}\") -ne \"${value}\"){ exit 1 }"
    }
    'absent': {
      $command = "[Environment]::SetEnvironmentVariable(\"${variable}\", \$null, \"${target}\")"
      $unless = "if ([Environment]::GetEnvironmentVariable(\"${variable}\", \"${target}\") -ne \$null){ exit 1 }"
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
    provider => 'powershell',
    notify   => Class['windows::refresh_environment'],
  }
}
