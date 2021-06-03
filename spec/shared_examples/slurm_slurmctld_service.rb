shared_examples_for 'slurm::slurmctld::service' do
  it do
    is_expected.to contain_file('/etc/sysconfig/slurmctld')
      .with_ensure('file')
      .with_owner('root')
      .with_group('root')
      .with_mode('0644')

    is_expected.to contain_service('slurmctld')
      .with_ensure('running')
      .with_enable('true')
      .with_hasstatus('true')
      .with_hasrestart('true')
      .that_comes_before('Exec[scontrol reconfig]')

    is_expected.to contain_exec('scontrol reconfig')
      .with_path(%r{/usr/bin})
      .with_command('scontrol reconfigure')
      .with_refreshonly('true')
  end

  context 'with defaults slurmctld should be reloaded on config change' do
    it { is_expected.to contain_file('/etc/sysconfig/slurmctld').with_notify('Exec[scontrol reconfig]') }
  end

  context 'with reload_services set to false and restart_services set to true slurmctld should get restart on config change' do
    let(:param_override) { { reload_services: false, restart_services: true } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmctld').with_notify('Service[slurmctld]') }
  end

  context 'with (reload|restart)_services set to false should do nothing on config change' do
    let(:param_override) { { reload_services: false } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmctld').with_notify(nil) }
  end
end
