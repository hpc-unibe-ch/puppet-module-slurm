# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`slurm`](#slurm): Main class that manages every aspect centrally

#### Private Classes

* `slurm::client`
* `slurm::common::install`
* `slurm::common::setup`
* `slurm::common::user`
* `slurm::slurmctld`
* `slurm::slurmctld::config`
* `slurm::slurmctld::service`
* `slurm::slurmd`
* `slurm::slurmd::config`
* `slurm::slurmd::service`
* `slurm::slurmdbd`
* `slurm::slurmdbd::config`
* `slurm::slurmdbd::service`

## Classes

### <a name="slurm"></a>`slurm`

This module currently orchestrates every installation aspect. However it does not
configure Slurm in terms of contents in /etc/slurm (slurm.conf# gres.conf, ...).
These aspects have to be handled elsewhere, i.e. in a separate git repository.

Currently the module manages:
* Installation of RPMs for the selected features
* Creation of user and group slurm
* Manage files, directories and services accoridng to the selected features

Features supported include:
* client: only slurm commands, no additional services running
* slurmd: slurm daemom is installed and started
* slurmdbd: slurm database daemon is installed and started
* slurmctld: slurm control daemon is installed and started

Features can be added up on the same node!

Note on config: Just store contents of `/etc/slurm` in a git repo
and clone it on your shared filesystem to the final path using
`puppetlabs-vcsrepo`.

 }

Slurm user and group management related options

#### Examples

##### Basic setup of a compute node with memlock set to unlimited and increased number of open files

```puppet
class { 'slurm':
  slurmd                => true,
  slurmd_service_limits => {
    'LimitMEMLOCK' => 'infinity',
    'LimitNOFILE'  => 8192,
  },
  manage_firewall       => true,
```

##### Setup of a slurm master with slurmctld and slurmdbd on the same host; reloading services is prevented

```puppet
class { 'slurm':
  slurmdbd        => true,
  slurmctld       => true,
  reload_services => false,
}
```

#### Parameters

The following parameters are available in the `slurm` class:

* [`client`](#client)
* [`slurmd`](#slurmd)
* [`slurmdbd`](#slurmdbd)
* [`slurmctld`](#slurmctld)
* [`package_ensure`](#package_ensure)
* [`manage_slurm_user`](#manage_slurm_user)
* [`slurm_user`](#slurm_user)
* [`slurm_user_uid`](#slurm_user_uid)
* [`slurm_group`](#slurm_group)
* [`slurm_group_gid`](#slurm_group_gid)
* [`reload_services`](#reload_services)
* [`restart_services`](#restart_services)
* [`slurmd_service_ensure`](#slurmd_service_ensure)
* [`slurmd_service_enable`](#slurmd_service_enable)
* [`slurmd_service_limits`](#slurmd_service_limits)
* [`slurmdbd_service_ensure`](#slurmdbd_service_ensure)
* [`slurmdbd_service_enable`](#slurmdbd_service_enable)
* [`slurmdbd_service_limits`](#slurmdbd_service_limits)
* [`slurmctld_service_ensure`](#slurmctld_service_ensure)
* [`slurmctld_service_enable`](#slurmctld_service_enable)
* [`slurmctld_service_limits`](#slurmctld_service_limits)
* [`manage_logrotate`](#manage_logrotate)
* [`manage_firewall`](#manage_firewall)

##### <a name="client"></a>`client`

Data type: `Optional[Boolean]`

The feature only installs the basic commands; no daemons get deployed; defaults s true

##### <a name="slurmd"></a>`slurmd`

Data type: `Optional[Boolean]`

The feature installis the slurm daemon, useful on a compute node; default is false

##### <a name="slurmdbd"></a>`slurmdbd`

Data type: `Optional[Boolean]`

This feature installs the slurm database daemon to talk to a MySQL database server: default is false

##### <a name="slurmctld"></a>`slurmctld`

Data type: `Optional[Boolean]`

This feature installs the slurm control daemon: default is false

##### <a name="package_ensure"></a>`package_ensure`

Data type: `Optional[String]`

The defeault package ensure is set to 'present'; use other values if needed

##### <a name="manage_slurm_user"></a>`manage_slurm_user`

Data type: `Optional[Boolean]`

Should the module deploy user and gropu to be used for slurm aspects; defaults to true

##### <a name="slurm_user"></a>`slurm_user`

Data type: `Optional[String]`

The username to use for ownerships of files/directories and services; default is 'slurm'

##### <a name="slurm_user_uid"></a>`slurm_user_uid`

Data type: `Optional[Integer]`

The numeric id for the slurm user; default is 468

##### <a name="slurm_group"></a>`slurm_group`

Data type: `Optional[String]`

The group name to use for ownerships of files/directories and services; default is 'slurm'

##### <a name="slurm_group_gid"></a>`slurm_group_gid`

Data type: `Optional[Integer]`

The numeric id for the slurm group; default is 468

##### <a name="reload_services"></a>`reload_services`

Data type: `Optional[Boolean]`

If changes to configuration files occur, should a relaod of the services be done automatically? Default is true

##### <a name="restart_services"></a>`restart_services`

Data type: `Optional[Boolean]`

If changes to configuration files occur, should a restart of the services be done automatically; default is false

##### <a name="slurmd_service_ensure"></a>`slurmd_service_ensure`

Data type: `Optional[String]`

The defualt state of the slurm daemon; default is 'running'

##### <a name="slurmd_service_enable"></a>`slurmd_service_enable`

Data type: `Optional[Boolean]`

Should the slurm daemon be enabled by systemd; default is true

##### <a name="slurmd_service_limits"></a>`slurmd_service_limits`

Data type: `Optional[Hash]`

A hash of system resource limits for the slurm daemon, see example; default is empty hash

##### <a name="slurmdbd_service_ensure"></a>`slurmdbd_service_ensure`

Data type: `Optional[String]`

The defualt state of the slurm database daemon; default is 'running'

##### <a name="slurmdbd_service_enable"></a>`slurmdbd_service_enable`

Data type: `Optional[Boolean]`

Should the slurm database daemon be enabled by systemd; default is true

##### <a name="slurmdbd_service_limits"></a>`slurmdbd_service_limits`

Data type: `Optional[Hash]`

A hash of system resource limits for the slurm database daemon, see example; default is empty hash

##### <a name="slurmctld_service_ensure"></a>`slurmctld_service_ensure`

Data type: `Optional[String]`

The defualt state of the slurm control daemon; default is 'running'

##### <a name="slurmctld_service_enable"></a>`slurmctld_service_enable`

Data type: `Optional[Boolean]`

Should the slurm control daemon be enabled by systemd; default is true

##### <a name="slurmctld_service_limits"></a>`slurmctld_service_limits`

Data type: `Optional[Hash]`

A hash of system resource limits for the slurm control daemon, see example; default is empty hash

##### <a name="manage_logrotate"></a>`manage_logrotate`

Data type: `Optional[Boolean]`

Should the module manage the logrotaiton of slurm logs; default is true

##### <a name="manage_firewall"></a>`manage_firewall`

Data type: `Optional[Boolean]`

Should the module configure the firewall rules for installed services; default is false

