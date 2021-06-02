def base_packages
  [
    'slurm',
    'slurm-contribs',
    'slurm-devel',
    'slurm-perlapi',
    'slurm-libpmi',
  ]
end

shared_examples_for 'slurm::common::install' do
  base_packages.each do |p|
    it { is_expected.to contain_package(p).with_ensure('present').without_require }
  end

  context 'when version is set to "20.02.0-1.el7"' do
    let(:param_override) { { package_ensure: '20.02.0-1.el7' } }

    base_packages.each do |p|
      it { is_expected.to contain_package(p).with_ensure('20.02.0-1.el7').without_require }
    end
  end
end

shared_examples_for 'slurm::common::install-slurmd' do
  it { is_expected.to contain_package('slurm-slurmd').with_ensure('present').without_require }
end
shared_examples_for 'slurm::common::install-slurmctld' do
  it { is_expected.to contain_package('slurm-slurmctld').with_ensure('present').without_require }
end
shared_examples_for 'slurm::common::install-slurmdbd' do
  it { is_expected.to contain_package('slurm-slurmdbd').with_ensure('present').without_require }
end
