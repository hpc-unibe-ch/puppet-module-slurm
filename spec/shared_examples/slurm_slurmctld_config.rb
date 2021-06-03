shared_examples_for 'slurm::slurmctld::config' do
  it do
    is_expected.to contain_file('StateSaveLocation')
      .with_ensure('directory')
      .with_path('/var/spool/slurmctld.state')
      .with_owner('slurm')
      .with_group('slurm')
      .with_mode('0700')

    is_expected.to contain_file('JobCheckpointDir')
      .with_ensure('directory')
      .with_path('/var/spool/slurmctld.checkpoint')
      .with_owner('slurm')
      .with_group('slurm')
      .with_mode('0700')
  end
end
