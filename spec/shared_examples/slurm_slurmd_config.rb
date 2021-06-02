shared_examples_for 'slurm::slurmd::config' do
  it do
    is_expected.to contain_file('SlurmdSpoolDir')
      .with_ensure('directory')
      .with_path('/var/spool/slurmd.spool')
      .with_owner('slurm')
      .with_group('slurm')
      .with_mode('0755')
  end
end
