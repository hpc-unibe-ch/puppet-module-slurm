# @summary Main class that manages every aspect centrally
#
# This module currently orchestrates every installation aspect. However it does not
# configure Slurm in terms of contents in /etc/slurm (slurm.conf# gres.conf, ...).
# These aspects have to be handled elsewhere, i.e. in a separate git repository.
#
# Currently the module manages:
# * Installation of RPMs for the selected features
# * Creation of user and group slurm
# * Manage files, directories and services accoridng to the selected features
#
# Features supported include:
# * client: only slurm commands, no additional services running
# * slurmd: slurm daemom is installed and started
# * slurmdbd: slurm database daemon is installed and started
# * slurmctld: slurm control daemon is installed and started
#
# Features can be added up on the same node!
#
# Note on config: Just store contents of `/etc/slurm` in a git repo
# and clone it on your shared filesystem to the final path using
# `puppetlabs-vcsrepo`.
#
# @example Basic setup of a compute node with memlock set to unlimited and increased number of open files
#   class { 'slurm':
#     slurmd                => true,
#     slurmd_service_limits => {
#       'LimitMEMLOCK' => 'infinity',
#       'LimitNOFILE'  => 8192,
#     },
#     manage_firewall       => true,
#  }
#
# @example Setup of a slurm master with slurmctld and slurmdbd on the same host; reloading services is prevented
#   class { 'slurm':
#     slurmdbd        => true,
#     slurmctld       => true,
#     reload_services => false,
#   }
#
# @param client
#   The feature only installs the basic commands; no daemons get deployed; defaults s true
# @param slurmd
#   The feature installis the slurm daemon, useful on a compute node; default is false
# @param slurmdbd
#   This feature installs the slurm database daemon to talk to a MySQL database server: default is false
# @param slurmctld
#   This feature installs the slurm control daemon: default is false
# @param package_ensure
#   The defeault package ensure is set to 'present'; use other values if needed
# Slurm user and group management related options
# @param manage_slurm_user
#   Should the module deploy user and gropu to be used for slurm aspects; defaults to true
# @param slurm_user
#   The username to use for ownerships of files/directories and services; default is 'slurm'
# @param slurm_user_uid
#   The numeric id for the slurm user; default is 468
# @param slurm_group
#   The group name to use for ownerships of files/directories and services; default is 'slurm'
# @param slurm_group_gid
#   The numeric id for the slurm group; default is 468
# @param reload_services
#   If changes to configuration files occur, should a relaod of the services be done automatically? Default is true
# @param restart_services
#   If changes to configuration files occur, should a restart of the services be done automatically; default is false
# @param slurmd_service_ensure
#   The defualt state of the slurm daemon; default is 'running'
# @param slurmd_service_enable
#   Should the slurm daemon be enabled by systemd; default is true
# @param slurmd_service_limits
#   A hash of system resource limits for the slurm daemon, see example; default is empty hash
# @param slurmdbd_service_ensure
#   The defualt state of the slurm database daemon; default is 'running'
# @param slurmdbd_service_enable
#   Should the slurm database daemon be enabled by systemd; default is true
# @param slurmdbd_service_limits
#   A hash of system resource limits for the slurm database daemon, see example; default is empty hash
# @param slurmctld_service_ensure
#   The defualt state of the slurm control daemon; default is 'running'
# @param slurmctld_service_enable
#   Should the slurm control daemon be enabled by systemd; default is true
# @param slurmctld_service_limits
#   A hash of system resource limits for the slurm control daemon, see example; default is empty hash
# @param manage_logrotate
#   Should the module manage the logrotaiton of slurm logs; default is true
# @param manage_firewall
#   Should the module configure the firewall rules for installed services; default is false
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
  Optional[String]  $slurm_group,
  Optional[Integer] $slurm_group_gid,
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

  # Compute which resources are to be notified and how to notify these on changes
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

  # in addition combine the ones not undef to an array for later use in slurm::common::install
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
