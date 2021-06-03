# slurm

## Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
    * [What slurm affects](#what-slurm-affects)
    * [Setup Requirements](#setup-requirements)
    * [Beginning with slurm](#beginning-with-slurm)
* [Usage](#usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)

<!-- vim-markdown-toc -->

## Description

This slurm module is a downsized version of [treydock/slurm](https://forge.puppet.com/treydock/slurm).
Its complexity is reduced by removing all aspects of configuring slum. In short, every aspect that is done in the "slurm dir"
is removed, i.e. managing partitions, QOS, users, GRES. We at our site are manging the contents of `/etc/slurm` in its own
git repository independent from managing packges, files and daemons.

## Setup

### What slurm affects

In short this module only installs relevant packages and dependencies, deploys files and directories (state, log, logroration...)
and manages daemons and firewall rules.

### Setup Requirements

The module's design allows changing the most important things through the `slurm` class. The daemons getting installed are chosen
by the setting the respective attributes to true. More than one role can be deployed on a host, e.g. `slurmdbd` and `slurmctld`. See
usage examples below.

In order to use SLURM the munge daemon must be configured and a munge key has to be deployed. This module does not manage neither
of them. Instead make use of an additional module like [treydock/munge](https://forge.puppet.com/treydock/munge).

Instead of declaring the attributes within the a manifest it's perfectly possible to provide the configuration data in hiera. The
module itself is using hiera for its default data.

### Beginning with slurm

By just including the `slurm` class as follow, the node is setup as a SLURM client and the defaults
set in module's `common.yaml` is applied:

```
include slurm
```

Other use cases are outlined in the right below.

## Usage

By just including the class `slurm` the given host acts as a SLURM client. This is the role primarily used on thing like
login nodes.

On a worker node the daemon `slurmd` is needed. To designate a node as a worker node, the following snippet will do the job.

```
class { 'slurm':
  slurmd => true,
}
```

Likewise for the designation of a slurm control daemon, the parameter `slurmctld` is used. In the following example, not only the
control daemon gets installed but also the `slurmdbd` daemon to connect to a MySQSL database server. Setting up the database server
itself is out of the scope of this module and has to be installed elsewhere.

```
class { 'slurm':
  slurmdbd  => true,
  slurmctld => true,
}
```

All of the parameters can also be set by putting the configuration data to hiera and make use automatic parameter binding feature of Puppet.

For all possible configuration parameters the reference below should be consulted.

## Reference

See [REFRENCE.md](REFERENCE.md) in this repository.

## Limitations

This module is currently only tested on CentOS-7.

## Development

This project is using PDK and feature unit tests. In order to participate, please take the time
to get into it to if not already familiar with.

If you want to contribute to this project:
* File an issue over at [github.com](https://github.com/hpc-unibe-ch/puppet-module-slurm/issues) telling us about the changes you have mind
* Fork the repository and make your changes on a feature branch
* Genereate a pull request against the `main` branch. Don't forget to rebase before creating a PR.
