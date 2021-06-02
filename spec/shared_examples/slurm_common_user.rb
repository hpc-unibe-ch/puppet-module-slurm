shared_examples_for 'slurm::common::user' do
  context 'when using defaults provided in module data' do
    it do
      is_expected.to contain_group('slurm')
        .with_ensure('present')
        .with_name('slurm')
        .with_gid(468)
        .with_forcelocal('true')
        .with_system('true')
    end

    it do
      is_expected.to contain_user('slurm')
        .with_ensure('present')
        .with_name('slurm')
        .with_uid(468)
        .with_gid(468)
        .with_shell('/sbin/nologin')
        .with_home('/var/lib/slurm')
        .with_managehome('true')
        .with_comment('SLURM User')
        .with_forcelocal('true')
        .with_system('true')
    end
  end

  context 'when slurm_group_gid is set to 400' do
    let(:params) { param_override.merge(slurm_group_gid: 400) }

    it { is_expected.to contain_group('slurm').with_gid('400') }
  end

  context 'when slurm_user_uid is set to 400' do
    let(:params) { param_override.merge(slurm_user_uid: 400) }

    it { is_expected.to contain_user('slurm').with_uid('400') }
  end

  context 'when manage_slurm_user is set to false' do
    let(:params) { param_override.merge(manage_slurm_user: false) }

    it { is_expected.not_to contain_group('slurm') }
    it { is_expected.not_to contain_user('slurm') }
  end
end
