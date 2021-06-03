shared_examples_for 'slurm::slurmdbd::config' do
  it do
    is_expected.to contain_file('slurmdbd-ArchiveDir')
      .with_ensure('directory')
      .with_path('/var/lib/slurmdbd.archive')
      .with_owner('slurm')
      .with_group('slurm')
      .with_mode('0700')
  end
end
