# @api private
class slurm::common::install {

  # First install dependencies needed before disabling EPEL
  ['hdf5', 'libaec', 'pmix'].each |String $package| {
    package { $package:
      ensure => present,
    }
  }

  # Standard paramters for all package resources later
  # Dsiable EPEL as we have our own packages, which would
  # collide with the ones newly provided by EPEL!
  Package {
    ensure          => $slurm::package_ensure,
    install_options => { '--disablerepo' => 'epel' },
    notify          => $slurm::service_notify,
  }

  # Common packages used on every machine
  if $slurm::slurmd or $slurm::slurmctld or $slurm::client {
    package { 'slurm': }
    package { 'slurm-contribs': }
    package { 'slurm-devel': }
    package { 'slurm-perlapi': }
    package { 'slurm-libpmi': }
  }

  if $slurm::slurmd {
    package { 'slurm-slurmd': }
  }

  if $slurm::slurmctld {
    package { 'slurm-slurmctld': }
  }

  if $slurm::slurmdbd {
    package { 'slurm-slurmdbd': }
  }
}
