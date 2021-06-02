shared_examples_for 'slurm::common::setup' do
  it do
    is_expected.to contain_file('slurm confdir')
      .with_ensure('directory')
      .with_path('/etc/slurm')
      .with_owner('root')
      .with_group('root')
      .with_mode('0755')
  end

  it do
    if slurmctld || slurmd || slurmdbd
      is_expected.to contain_file('/var/log/slurm')
        .with_ensure('directory')
        .with_owner('slurm')
        .with_group('slurm')
        .with_mode('0750')
    else
      is_expected.not_to contain_file('/var/log/slurm')
    end
  end

  it do
    if slurmctld || slurmd || slurmdbd
      is_expected.to contain_logrotate__rule('slurm')
        .with_path('/var/log/slurm/*.log')
        .with_compress('true')
        .with_missingok('true')
        .with_copytruncate('false')
        .with_delaycompress('false')
        .with_ifempty('false')
        .with_rotate('10')
        .with_sharedscripts('true')
        .with_size('10M')
        .with_create('true')
        .with_create_mode('0640')
        .with_create_owner('slurm')
        .with_create_group('root')
        .with_postrotate([
                           'pkill -x --signal SIGUSR2 slurmctld',
                           'pkill -x --signal SIGUSR2 slurmd',
                           'pkill -x --signal SIGUSR2 slurmdbd',
                           'exit 0',
                         ])
    else
      is_expected.not_to contain_logrotate__rule('slurm')
    end
  end

  context 'when manage_logrotate => false' do
    let(:param_override) { { manage_logrotate: false } }

    it { is_expected.not_to contain_logrotate__rule('slurm') }
  end
end
