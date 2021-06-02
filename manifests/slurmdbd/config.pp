# @api private
class slurm::slurmdbd::config {

  file { 'slurmdbd-ArchiveDir':
    ensure => 'directory',
    path   => $slurm::slurmdbd_archive_dir,
    owner  => $slurm::slurm_user,
    group  => $slurm::slurm_group,
    mode   => '0700',
  }
}
