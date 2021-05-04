# frozen_string_literal: true

require 'spec_helper'

describe 'slurm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'and no feature requested' do
        let(:params) do
          {
            'client' => false,
            'slurmd' => false,
            'slurmdbd' => false,
            'slurmctld' => false,
          }
        end

        it { is_expected.to compile.and_raise_error(%r{no slurm feature has been selected}i) }
      end
    end
  end
end
