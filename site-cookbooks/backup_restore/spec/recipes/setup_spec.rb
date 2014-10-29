require_relative '../spec_helper'

describe 'backup_restore::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  let(:chef_run_backup_options) do
    runner =  ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ) do |node|
      node.set['backup']['version'] = '4.1.0' # => Default nil => 4.0.2
      node.set['backup']['upgrade?'] = true   # => Default false
    end
    runner.converge(described_recipe)
  end

  it 'include cron' do
    expect(chef_run).to include_recipe 'cron::default'
  end

  it 'install backup gem' do
    expect(chef_run).to install_gem_package('backup').with(
      version: nil,
      options: '--no-ri --no-rdoc'
    )
  end

  it 'install backup gem and set atributes' do
    expect(chef_run_backup_options).to upgrade_gem_package('backup').with(
      version: '4.1.0',
      options: '--no-ri --no-rdoc'
    )
  end

  it 'include backup' do
    expect(chef_run).to include_recipe 'backup::default'
  end

  it 'include percona' do
    expect(chef_run).to include_recipe 'percona::backup'
  end

  it 'create a link to backup bin' do
    #IO::File.stub(:exist?).and_call_original
    #IO::File.stub(:exist?).with('/root/.chefdk/gem/ruby/2.1.0/bin/backup').and_return(true)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/root/.chefdk/gem/ruby/2.1.0/bin/backup').and_return(true)
    link = chef_run.link('/usr/local/bin/backup')
    expect(link).to link_to('/root/.chefdk/gem/ruby/2.1.0/bin/backup')
  end

  describe 'for s3' do
    it 'include yum-epel' do
      expect(chef_run).to include_recipe 'yum-epel::default'
    end

    it 'include s3cmd-master' do
      expect(chef_run).to include_recipe 's3cmd-master::default'
    end

    it 'install python-dateutil' do
      expect(chef_run).to install_package 'python-dateutil'
    end
  end
end
