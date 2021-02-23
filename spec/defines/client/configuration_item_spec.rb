# frozen_string_literal: true

require 'spec_helper'

describe 'check_mk::client::configuration_item' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        'contain check_mk::client'
      end

      it { is_expected.to compile }
    end
  end
end
