class oracle-xe {

  $oracle_rpm = "oracle-xe-11.2.0-1.0.x86_64.rpm"
  $oracle_rpm_tmp = "/tmp/$oracle_rpm"

  file { 'oracle-xe-rpm':
    path   => "$oracle_rpm_tmp",
    ensure => file,
    source => "puppet:///modules/oracle-xe/$oracle_rpm",
    mode   => 0444,
    owner  => root,
    group  => root,
  }

  package { 'oracle-xe':
    ensure => present,
    source => "$oracle_rpm_tmp",
  }

  file { 'oracle-xe-conf':
    path   => '/etc/sysconfig/oracle-xe',
    ensure => file,
    source => 'puppet:///modules/oracle-xe/oracle-xe.conf',
    mode   => 0444,
    owner  => root,
    group  => root,
  }

  service { 'oracle-xe':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus  => true,
  }

  File['oracle-xe-rpm'] -> Package['oracle-xe']
  Package['oracle-xe'] -> File['oracle-xe-conf']
  File['oracle-xe-conf'] -> Service['oracle-xe']
}

