shared_examples_for 'slurm::slurmdbd' do
  it { is_expected.to contain_class('slurm::common::user').that_comes_before('Class[slurm::common::install]') }
  it { is_expected.to contain_class('slurm::common::install').that_comes_before('Class[slurm::common::setup]') }
  it { is_expected.to contain_class('slurm::common::setup').that_comes_before('Class[slurm::slurmdbd::config]') }
  it { is_expected.to contain_class('slurm::slurmdbd::config').that_comes_before('Class[slurm::slurmdbd::service]') }
  it { is_expected.to contain_class('slurm::slurmdbd::service') }

  it_behaves_like 'slurm::common::user'
  it_behaves_like 'slurm::common::install-slurmdbd'
  it_behaves_like 'slurm::common::setup'
  it_behaves_like 'slurm::slurmdbd::config'
  it_behaves_like 'slurm::slurmdbd::service'

  it { is_expected.not_to contain_firewall('100 allow access to slurmdbd') }

  context 'and when manage_firewall is set to true' do
    let(:param_override) { { manage_firewall: true } }

    it do
      is_expected.to contain_firewall('100 allow access to slurmdbd')
        .with_proto('tcp')
        .with_dport('6819')
        .with_action('accept')
    end
  end
end
