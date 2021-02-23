# frozen_string_literal: true

require 'spec_helper'

describe 'check_mk::client::configuration_item' do
  let(:title) { 'namevar' }
  let(:pre_condition) do
    'contain check_mk::client'
  end
  let(:params) do
    {
      config: 'configcontent',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      end

      it { is_expected.to compile }
    end
  end
end
