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

  # Manage firewall if requested but only open the port only if
  # roles slurmctld and slurmdbd are not on the same host
  if $slurm::manage_firewall and ! ($slurm::slurmdbd and $slurm::slurmctld)  {
    firewall {'100 allow access to slurmdbd':
      proto  => 'tcp',
      dport  => $slurm::slurmdbd_port,
      action => 'accept'
    }
  }
}
