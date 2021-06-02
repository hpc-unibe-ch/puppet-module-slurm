shared_examples_for 'slurm::slurmd::service' do
  it do
    is_expected.to contain_file('/etc/sysconfig/slurmd')
      .with_ensure('file')
      .with_owner('root')
      .with_group('root')
      .with_mode('0644')
  end

  it do
    is_expected.to contain_service('slurmd')
      .with_ensure('running')
      .with_enable('true')
      .with_hasstatus('true')
      .with_hasrestart('true')
  end

  context 'with defaults slurmd should be reloaded on config change' do
    it { is_expected.to contain_file('/etc/sysconfig/slurmd').with_notify('Exec[slurmd reload]') }
  end

  context 'with reload_services set to false and restart_services set to true slurmd should get restart on config change' do
    let(:param_override) { { reload_services: false, restart_services: true } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmd').with_notify('Service[slurmd]') }
  end

  context 'with {reload|restart)_services set to false should do nothing on config change' do
    let(:param_override) { { reload_services: false } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmd').with_notify(nil) }
  end
end
