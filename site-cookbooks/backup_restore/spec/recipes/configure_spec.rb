require_relative '../spec_helper'

describe 'backup_restore::configure' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    )do |node|
      node.set['backup_restore']['config']['use_proxy'] = true
      node.set['backup_restore']['config']['proxy_host'] = 'localhost'
      node.set['backup_restore']['config']['proxy_port'] = '8080'
      node.set['backup_restore']['sources']['enabled'] = %w(postgresql)
      node.set['backup_restore']['destinations']['enabled'] = %w(s3)
      node.set['backup_restore']['destinations']['s3'] = {
        bucket: 's3bucket',
        access_key_id: 'access_key_id',
        secret_access_key: 'secret_access_key',
        region: 'us-east-1',
        prefix: '/backup'
      }
    end

    runner.converge(described_recipe)
  end

  it 's3 config' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :s3cfg,
      :create,
      '/root/.s3cfg'
    ).with(
      access_key: 'access_key_id',
      secret_key: 'secret_access_key',
      owner: 'root',
      group: 'root',
      install_s3cmd: false,
      config: {
        "proxy_host" => 'localhost',
        "proxy_port" => '8080',
        "use_https" => false
      }
    )
  end

  it 'create log directory' do
    expect(chef_run).to create_directory('/var/log/backup').with(
      owner: 'root',
      group: 'root'
    )
  end

  it 'include directory configure' do
    expect(chef_run).to include_recipe('backup_restore::configure_postgresql')
  end
end
