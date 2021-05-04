# @api private
class slurm::common::setup {

    file { 'slurm confdir':
    ensure => 'directory',
    path   => $slurm::conf_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Don't need these directories on a client - all other roles need them
  if $slurm::slurmctld or $slurm::slurmdbd or $slurm::slurmd {
    file { $slurm::log_dir:
      ensure => 'directory',
      owner  => $slurm::slurm_user,
      group  => $slurm::slurm_user_group,
      mode   => '0750',
    }

    if $slurm::manage_logrotate {
      #Refer to: http://slurm.schedmd.com/slurm.conf.html#SECTION_LOGGING
      logrotate::rule { 'slurm':
        path          => "${slurm::log_dir}/*.log",
        compress      => true,
        missingok     => true,
        copytruncate  => false,
        delaycompress => false,
        ifempty       => false,
        rotate        => 10,
        sharedscripts => true,
        size          => '10M',
        create        => true,
        create_mode   => '0640',
        create_owner  => $slurm::slurm_user,
        create_group  => 'root',
        postrotate    => [
          'pkill -x --signal SIGUSR2 slurmctld',
          'pkill -x --signal SIGUSR2 slurmd',
          'pkill -x --signal SIGUSR2 slurmdbd',
          'exit 0',
        ],
      }
    }
  }
}
