class oracle-xe (
  $http_port = 8080,
  $listener_port = 1521,
  $ipv6 = false,
  $startup = 'y',
  $password,
  $iniface = undef,
) {

  $oracle_rpm = "oracle-xe-11.2.0-1.0.x86_64.rpm"
  $oracle_rpm_tmp = "/tmp/$oracle_rpm"
  $oracle_swap_script = "/u01/app/oracle/local/swap.sh"

  file { 'oracle-xe-rpm':
    path   => "$oracle_rpm_tmp",
    ensure => file,
    source => "puppet:///modules/oracle-xe/$oracle_rpm",
    mode   => 0444,
    owner  => root,
    group  => root,
  }

  file { [ '/u01', '/u01/app', '/u01/app/oracle', '/u01/app/oracle/local']:
    ensure      => directory,
    before      => File['oracle-swap'],
    refreshonly => true,
  }

  file { 'oracle-swap':
    path   => "$oracle_swap_script",
    ensure => file,
    source => "puppet:///modules/oracle-xe/swap.sh",
    mode   => 0544,
    owner  => root,
    group  => root,
    before => Exec['oracle-swap'],
  }

  # Swap must exceed Oracle's minimum when installed
  exec { 'oracle-swap':
    command => "$oracle_swap_script",
    before  => Package['oracle-xe'],
  }

  # only necessary because we don't use yum to install the main package
  package { 'libaio': 
    ensure => 'latest',
    before => Package['oracle-xe'],
  }

  package { 'oracle-xe':
    ensure   => present,
    source   => "$oracle_rpm_tmp",
    provider => 'rpm',
  }

  exec { 'oracle-xe-conf':
    creates => '/etc/sysconfig/oracle-xe',
    command => "/usr/bin/printf \"$http_port\\n$listener_port\\n$password\\n$password\\n$startup\\n\" | /etc/init.d/oracle-xe configure",
  }

  service { 'oracle-xe':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus  => true,
  }

  firewall { '100 oracle':
    action   => 'accept',
    dport    => ["$listener_port", "$http_port"],
    proto    => 'tcp',
    iniface  => $iniface,
    provider => $ipv6 ? {
      true   => 'ip6tables',
      false  => 'iptables',
    }
  }

  File['oracle-xe-rpm'] -> Package['oracle-xe']
  Package['oracle-xe'] -> Exec['oracle-xe-conf']
  Exec['oracle-xe-conf'] -> Service['oracle-xe']
  Service['oracle-xe'] -> Firewall['100 oracle']
}
