# @api private
class slurm::slurmdbd::service {

  file { '/etc/sysconfig/slurmdbd':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('slurm/sysconfig/slurmdbd.erb'),
    notify  => $slurm::slurmdbd_notify,
  }

  if ! empty($slurm::slurmdbd_service_limits) {
    systemd::service_limits { 'slurmdbd.service':
      limits          => $slurm::sslurmdbd_service_limits,
      restart_service => false,
      notify          => $slurm::slurmdbd_notify,
    }
  }

  service { 'slurmdbd':
    ensure     => $slurm::slurmdbd_service_ensure,
    enable     => $slurm::slurmdbd_service_enable,
    hasstatus  => true,
    hasrestart => true,
  }

  exec { 'slurmdbd reload':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => 'systemctl reload slurmdbd',
    refreshonly => true,
    require     => Service['slurmdbd'],
  }
}
