# @api private
class slurm::slurmd {

  contain slurm::common::user
  contain slurm::common::install
  contain slurm::common::setup
  contain slurm::slurmd::config
  contain slurm::slurmd::service

  Class['slurm::common::user']
  -> Class['slurm::common::install']
  -> Class['slurm::common::setup']
  -> Class['slurm::slurmd::config']
  -> Class['slurm::slurmd::service']

  if $slurm::manage_firewall {
    firewall { '100 allow access to slurmd':
      proto  => 'tcp',
      dport  => $slurm::slurmd_port,
      action => 'accept'
    }
  }
}
