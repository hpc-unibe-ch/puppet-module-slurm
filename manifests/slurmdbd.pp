# @api private
class slurm::slurmdbd {

  contain slurm::common::user
  contain slurm::common::install
  contain slurm::common::setup
  contain slurm::slurmdbd::config
  contain slurm::slurmdbd::service

  Class['slurm::common::user']
  -> Class['slurm::common::install']
  -> Class['slurm::common::setup']
  -> Class['slurm::slurmdbd::config']
  -> Class['slurm::slurmdbd::service']

  # Always open slurmdbd port on host. sacct and sacctmgr
  # need to talk slurmdbd too.
  if $slurm::manage_firewall {
    firewall {'100 allow access to slurmdbd':
      proto  => 'tcp',
      dport  => $slurm::slurmdbd_port,
      action => 'accept'
    }
  }
}
