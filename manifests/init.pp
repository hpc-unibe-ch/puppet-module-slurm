# @summary Simplicistic module to manage Slurm installation
#
# This module currently helps to install. However it does not
# configure Slurm in terms of contents in /etc/slurm (slurm.conf,
# gres.conf, ...). Currently the module manages:
# * Installation of RPMs for given role
# * Creation of user and group slurm
#
# Note on config: Just store contents of `/etc/slurm` in a git repo
# and clone it on your shared filesystem to the final path using
# `puppetlabs-vcsrepo`.
#
# @example
#   class { 'slurm':
#
class slurm (
  Optional[Boolean] $client,
  Optional[Boolean] $slurmd,
  Optional[Boolean] $slurmdbd,
  Optional[Boolean] $slurmctld,
  Optional[String]  $package_ensure,
  # Slurm user and group management related options
  Optional[Boolean] $manage_slurm_user,
  Optional[String]  $slurm_user,
  Optional[Integer] $slurm_user_uid,
  Optional[String]  $slurm_user_group,
  Optional[Integer] $slurm_user_group_gid,
  # Services related options
  Optional[Boolean] $reload_services,
  Optional[Boolean] $restart_services,
  Optional[String]  $slurmd_service_ensure,
  Optional[Boolean] $slurmd_service_enable,
  Optional[Hash]    $slurmd_service_limits,
  Optional[String]  $slurmdbd_service_ensure,
  Optional[Boolean] $slurmdbd_service_enable,
  Optional[Hash]    $slurmdbd_service_limits,
  Optional[String]  $slurmctld_service_ensure,
  Optional[Boolean] $slurmctld_service_enable,
  Optional[Hash]    $slurmctld_service_limits,
  # Other options
  Optional[Boolean] $manage_logrotate,
  Optional[Boolean] $manage_firewall,
) {

  $osfamily = fact('os.family')
  $osmajor = fact('os.release.major')
  $os = "${osfamily}-${osmajor}"
  $supported = ['RedHat-7','RedHat-8']
  if ! ($os in $supported) {
    fail("Unsupported OS: ${os}, module ${module_name} only supports RedHat 7 and 8")
  }

  ### Hardcoded options currently not overridable ###
  # Slurm user and group management related options
  $slurm_user_shell              = '/sbin/nologin'
  $slurm_user_home               = '/var/lib/slurm'
  $slurm_user_managehome         = true
  $slurm_user_comment            = 'SLURM User'
  # Managed directories
  $conf_dir                      = '/etc/slurm'
  $log_dir                       = '/var/log/slurm'
  $slurmd_spool_dir              = '/var/spool/slurmd.spool'
  $slurmdbd_archive_dir          = '/var/lib/slurmdbd.archive'
  $slurmctld_state_save_location = '/var/spool/slurmctld.state'
  $slurmctld_job_checkpoint_dir  = '/var/spool/slurmctld.checkpoint'
  # Network ports of daemons
  $slurmctld_port                = 6817
  $slurmd_port                   = 6818
  $slurmdbd_port                 = 6819
  # Additional daemon cli arguments
  $slurmctld_options             = ''
  $slurmd_options                = ''
  $slurmdbd_options              = ''
  # Configuration files
  $slurm_conf_path               = "${conf_dir}/slurm.conf"
  $topology_conf_path            = "${conf_dir}/topology.conf"
  $gres_conf_path                = "${conf_dir}/gres.conf"
  $slurmdbd_conf_path            = "${conf_dir}/slurmdbd.conf"
  $cgroup_conf_path              = "${conf_dir}/cgroup.conf"

  # Compute which services are to be notified and how to notify these on changes
  if $slurmd and $slurmd_service_ensure == 'running' and $reload_services and $facts['slurmd_version'] {
    $slurmd_notify = Exec['slurmd reload']
  } elsif $slurmd and $slurmd_service_ensure == 'running' and $restart_services {
    $slurmd_notify = Service['slurmd']
  } else {
    $slurmd_notify = undef
  }

  if $slurmctld and $slurmctld_service_ensure == 'running' and $reload_services and $facts['slurmctld_version'] {
    $slurmctld_notify = Exec['scontrol reconfig']
  } elsif $slurmctld and $slurmctld_service_ensure == 'running' and $restart_services {
    $slurmctld_notify = Service['slurmctld']
  } else {
    $slurmctld_notify = undef
  }

  if $slurmdbd and $slurmdbd_service_ensure == 'running' and $reload_services and $facts['slurmdbd_version'] {
    $slurmdbd_notify = Exec['slurmdbd reload']
  } elsif $slurmdbd and $slurmdbd_service_ensure == 'running' and $restart_services {
    $slurmdbd_notify = Service['slurmdbd']
  } else {
    $slurmdbd_notify = undef
  }
  # finally combine the ones not undef to an array for later use in slurm::common::install
  $service_notify = flatten([$slurmd_notify, $slurmctld_notify, $slurmdbd_notify]).filter |$val| { $val =~ NotUndef }

  if ! ($client or $slurmd or $slurmdbd or $slurmctld) {
    fail('No slurm feature has been selected. Select at least one of client, slurmd, slurmctld or slurmdbd.')
  }

  if $client {
    contain slurm::client
  }

  if $slurmd {
    contain slurm::slurmd
  }

  if $slurmdbd {
    contain slurm::slurmdbd
  }

  if $slurmctld {
    contain slurm::slurmctld
  }
}
