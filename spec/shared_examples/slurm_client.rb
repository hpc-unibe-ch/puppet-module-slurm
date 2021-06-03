shared_examples_for 'slurm::client' do
  it { is_expected.to contain_class('slurm::common::user').that_comes_before('Class[slurm::common::install]') }
  it { is_expected.to contain_class('slurm::common::install').that_comes_before('Class[slurm::common::setup]') }
  it { is_expected.to contain_class('slurm::common::setup') }

  it_behaves_like 'slurm::common::user'
  it_behaves_like 'slurm::common::install'
  it_behaves_like 'slurm::common::setup'
end
