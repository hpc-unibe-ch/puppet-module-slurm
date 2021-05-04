# @api private
class slurm::slurmd::config {

  file { 'SlurmdSpoolDir':
    ensure => 'directory',
    path   => $slurm::slurmd_spool_dir,
    owner  => $slurm::slurmd_user,
    group  => $slurm::slurmd_user_group,
    mode   => '0755',
  }
}
