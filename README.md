windows
=======

This module provides Puppet configurations for common Windows administration.

Windows Classes
---------------

### `windows::autologon`

Configures automatic logon for the system for the given user.  For example:

```puppet
class { 'windows::autologon':
  user     => 'justin',
  password => 's3kr1t',
}
```

### `windows::iis_express`

Downloads and installs [IIS Express 8](http://www.microsoft.com/en-ca/download/details.aspx?id=34679).

### `windows::java`

Automatically downloads and installs Java from Oracle.  Currently, it uses
Java 8 Update 60.  Use of this class implies your acceptance of the
[Oracle Binary Code License Agreement for SE Platform Products](http://www.oracle.com/technetwork/java/javase/terms/license/index.html).

### `windows::nssm`

Downloads and installs the [Non-Sucking Service Manager](http://nssm.cc/).

### `windows::power_scheme`

Sets the power scheme for the system, for example:

```puppet
class { 'windows::power_scheme':
  ensure => 'High performance',
}
```

### `windows::refresh_environment`

Contains an `exec` resource that will refresh the current environment --
used when modifying system variables and having them be reflected
without logging off and/or rebooting.   Notify this class after modifying
any system enviornment variable.

### `windows::update`

Configures automatic windows updates, consult its [source](manifests/update.pp) for
more information.


Windows Defined Types
---------------------

### `windows::environment`

Configures a windows environment variable, for example:

```puppet
windows::environment { 'PYTHONPATH':
  value => 'C:\my_python_path'
}
```

### `windows::firewall_rule`

Creates a Windows firewall rule, for a program or a local port.
Some examples:

```puppet
# Allow ICMP ping.
windows::firewall_rule { 'ICMP Ping':
  protocol => 'icmpv4:8,any',
}

# Allow Python 2.7.
windows::firewall_rule { 'python2.7':
  program => 'C:\Python27\python.exe',
}
```

### `windows::path`

Ensures that the given directory is a part of the Windows `%Path%`, e.g.:

```puppet
windows::path { 'C:\Python27': }
```

### `windows::regsvr32`

Registers a DLL (or other control) specificed by the resource's name as
a component in the registry.

### `windows::screen_saver`

Configures a screen saver (specified by the given user name).  For example,
this configures the blank screen saver for the user `justin` to engage after
10 minutes, and requiring a password to log back in:

```puppet
windows::screen_saver { 'justin':
  secure  => true,
  timeout => '10m',
}
```

### `windows::shortcut`

Configures a windows shortcut, for example:

```puppet
windows::shortcut { 'C:\Users\justin\Desktop\python.lnk':
  target      => 'C:\Python27\python.exe',
  description => 'Python 2.7',
}
```

### `windows::unzip`

Unzips a file on Windows using Microsoft native APIs.  For example:

```puppet
windows::unzip { 'C:\compressed.zip':
  destination => 'C:\dest',
  creates     => 'C:\dest\uncompressed.txt',
}
```

This assumes that the file `uncompressed.txt` exists in `C:\compressed.zip`

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.com/counsyl/puppet-windows
