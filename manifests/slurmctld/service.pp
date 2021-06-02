# @api private
class slurm::slurmctld::service {

  file { '/etc/sysconfig/slurmctld':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('slurm/sysconfig/slurmctld.erb'),
    notify  => $slurm::slurmctld_notify,
  }

  if ! empty($slurm::slurmctld_service_limits) {
    systemd::service_limits { 'slurmctld.service':
      limits          => $slurm::sslurmctld_service_limits,
      restart_service => false,
      notify          => $slurm::slurmctld_notify,
    }
  }

  service { 'slurmctld':
    ensure     => $slurm::slurmctld_service_ensure,
    enable     => $slurm::slurmctld_service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

  exec { 'scontrol reconfig':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    refreshonly => true,
    require     => Service['slurmctld'],
  }
}
