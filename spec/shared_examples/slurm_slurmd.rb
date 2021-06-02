shared_examples_for 'slurm::slurmd' do
  it { is_expected.to contain_class('slurm::common::user').that_comes_before('Class[slurm::common::install]') }
  it { is_expected.to contain_class('slurm::common::install').that_comes_before('Class[slurm::common::setup]') }
  it { is_expected.to contain_class('slurm::common::setup').that_comes_before('Class[slurm::slurmd::config]') }
  it { is_expected.to contain_class('slurm::slurmd::config').that_comes_before('Class[slurm::slurmd::service]') }
  it { is_expected.to contain_class('slurm::slurmd::service') }

  it_behaves_like 'slurm::common::user'
  it_behaves_like 'slurm::common::install'
  it_behaves_like 'slurm::common::setup'
  it_behaves_like 'slurm::slurmd::config'
  it_behaves_like 'slurm::slurmd::service'

  it { is_expected.not_to contain_firewall('100 allow access to slurmd') }

  context 'and when manage_firewall is set to true' do
    let(:param_override) { { manage_firewall: true } }

    it do
      is_expected.to contain_firewall('100 allow access to slurmd')
        .with_proto('tcp')
        .with_dport('6818')
        .with_action('accept')
    end
  end
end
