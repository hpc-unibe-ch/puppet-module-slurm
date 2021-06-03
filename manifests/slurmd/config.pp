# @api private
class slurm::slurmd::config {

  file { 'SlurmdSpoolDir':
    ensure => 'directory',
    path   => $slurm::slurmd_spool_dir,
    owner  => $slurm::slurm_user,
    group  => $slurm::slurm_group,
    mode   => '0755',
  }
}
