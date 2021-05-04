# @api private
class slurm::slurmctld {

  contain slurm::common::user
  contain slurm::common::install
  contain slurm::common::setup
  contain slurm::slurmctld::config
  contain slurm::slurmctld::service

  Class['slurm::common::user']
  -> Class['slurm::common::install']
  -> Class['slurm::common::setup']
  -> Class['slurm::slurmctld::config']
  -> Class['slurm::slurmctld::service']

  if $slurm::manage_firewall {
    firewall { '100 allow access to slurmctld':
      proto  => 'tcp',
      dport  => $slurm::slurmctld_port,
      action => 'accept'
    }
  }
}
