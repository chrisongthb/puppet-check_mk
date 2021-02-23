# frozen_string_literal: true

require 'spec_helper'

describe 'check_mk::client::configuration_item' do
  let(:title) { 'myconfig' }
  let(:pre_condition) do
    'contain check_mk::client'
  end
  let(:params) do
    {
      config: 'configcontent',
      item_path: '/etc/check_mk',
      mode: '0400',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file('/etc/check_mk/myconfig.cfg').with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0400',
          'content' => 'configcontent',
        )
      }
    end
  end
end
