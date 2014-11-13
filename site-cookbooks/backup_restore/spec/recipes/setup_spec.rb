require_relative '../spec_helper'

describe 'backup_restore::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'include cron' do
    expect(chef_run).to include_recipe 'cron::default'
  end

  it 'include cefault recipe of backup cookbook' do
    expect(chef_run).to include_recipe 'backup::default'
  end

  it 'include backup recipe of percona cookbook' do
    expect(chef_run).to include_recipe 'percona::backup'
  end

  it 'include default recipe of yum-epel cookbook' do
    expect(chef_run).to include_recipe 'yum-epel::default'
  end

  it 'include default recipe of s3cmd-master cookbook' do
    expect(chef_run).to include_recipe 's3cmd-master::default'
  end

  it 'install default recipe of python-dateutil cookbook' do
    expect(chef_run).to install_package 'python-dateutil'
  end

  it 'install backup gem' do
    expect(chef_run).to install_gem_package('backup').with(
      version: nil,
      options: '--no-ri --no-rdoc'
    )
  end

  describe 'backup gem version is specified' do
    it 'install the specified version gem' do
      version = '4.0.0'
      chef_run.node.set['backup']['version'] = version
      chef_run.converge(described_recipe)
      expect(chef_run).to install_gem_package('backup').with(
        version: version
      )
    end
  end

  describe 'is specified backup gem action as upgrade' do
    it 'upgrade backup gem' do
      chef_run.node.set['backup']['upgrade?'] = true
      chef_run.converge(described_recipe)
      expect(chef_run).to upgrade_gem_package('backup')
    end
  end

  it 'create a link to backup' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/root/.chefdk/gem/ruby/2.1.0/bin/backup').and_return(true)
    link = chef_run.link('/usr/local/bin/backup')
    expect(link).to link_to('/root/.chefdk/gem/ruby/2.1.0/bin/backup')
  end
end
