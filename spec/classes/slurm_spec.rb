# frozen_string_literal: true

require 'spec_helper'

describe 'slurm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          {
            slurmd_version: '20.02.6-1.el7',
            slurmdbd_version: '20.02.6-1.el7',
            slurmctld_version: '20.02.6-1.el7',
          },
        )
      end
      let(:param_override) { {} }
      let(:client) { true }
      let(:slurmd) { false }
      let(:slurmctld) { false }
      let(:slurmdbd) { false }
      let(:default_params) do
        {
          client: client,
          slurmd: slurmd,
          slurmdbd: slurmdbd,
          slurmctld: slurmctld,
        }
      end
      let(:params) { default_params.merge(param_override) }

      it { is_expected.to compile }

      context 'with no slurm feature requested' do
        let(:client) { false }

        it { is_expected.to compile.and_raise_error(%r{no slurm feature has been selected}i) }
      end

      context 'configured as client with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('slurm::client') }
        it { is_expected.not_to contain_class('slurm::slurmd') }
        it { is_expected.not_to contain_class('slurm::slurmctld') }
        it { is_expected.not_to contain_class('slurm::slurmdbd') }
        it { is_expected.not_to contain_class('slurm::slurmdbd::db') }

        it_behaves_like 'slurm::client'
      end

      context 'configured as slurmd with defaults' do
        let(:slurmd) { true }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('slurm::client') }
        it { is_expected.to contain_class('slurm::slurmd') }
        it { is_expected.not_to contain_class('slurm::slurmctld') }
        it { is_expected.not_to contain_class('slurm::slurmdbd') }
        it { is_expected.not_to contain_class('slurm::slurmdbd::db') }

        it_behaves_like 'slurm::slurmd'
      end

      context 'configured as slurmdbd with defaults' do
        let(:slurmdbd) { true }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('slurm::client') }
        it { is_expected.to contain_class('slurm::slurmdbd') }
        it { is_expected.not_to contain_class('slurm::slurmd') }
        it { is_expected.not_to contain_class('slurm::slurmctld') }
        it { is_expected.not_to contain_class('slurm::slurmdbd::db') }

        it_behaves_like 'slurm::slurmdbd'
      end

      context 'configured as slurmctld with defaults' do
        let(:slurmctld) { true }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('slurm::client') }
        it { is_expected.to contain_class('slurm::slurmctld') }
        it { is_expected.not_to contain_class('slurm::slurmd') }
        it { is_expected.not_to contain_class('slurm::slurmdbd') }
        it { is_expected.not_to contain_class('slurm::slurmdbd::db') }

        it_behaves_like 'slurm::slurmctld'
      end
    end
  end
end
