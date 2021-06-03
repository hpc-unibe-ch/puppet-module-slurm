shared_examples_for 'slurm::slurmdbd::service' do
  it do
    is_expected.to contain_file('/etc/sysconfig/slurmdbd')
      .with_ensure('file')
      .with_owner('root')
      .with_group('root')
      .with_mode('0644')

    is_expected.to contain_service('slurmdbd')
      .with_ensure('running')
      .with_enable('true')
      .with_hasstatus('true')
      .with_hasrestart('true')
      .that_comes_before('Exec[slurmdbd reload]')

    is_expected.to contain_exec('slurmdbd reload')
      .with_path(%r{/usr/bin})
      .with_command('systemctl reload slurmdbd')
      .with_refreshonly('true')
  end

  context 'with defaults slurmdbd should be reloaded on config change' do
    it { is_expected.to contain_file('/etc/sysconfig/slurmdbd').with_notify('Exec[slurmdbd reload]') }
  end

  context 'with reload_services set to false and restart_services set to true slurmdbd should get restart on config change' do
    let(:param_override) { { reload_services: false, restart_services: true } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmdbd').with_notify('Service[slurmdbd]') }
  end

  context 'with {reload|restart)_services set to false should do nothing on config change' do
    let(:param_override) { { reload_services: false } }

    it { is_expected.to contain_file('/etc/sysconfig/slurmdbd').with_notify(nil) }
  end
end
