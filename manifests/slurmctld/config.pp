# @api private
class slurm::slurmctld::config {

  file { 'StateSaveLocation':
    ensure => 'directory',
    path   => $slurm::slurmctld_state_save_location,
    owner  => $slurm::slurm_user,
    group  => $slurm::slurm_user_group,
    mode   => '0700',
  }

  file { 'JobCheckpointDir':
    ensure => 'directory',
    path   => $slurm::slurmctld_job_checkpoint_dir,
    owner  => $slurm::slurm_user,
    group  => $slurm::slurm_user_group,
    mode   => '0700',
  }
}
