require_relative '../spec_helper'

describe 'backup_restore::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  describe 's3 is enabled as a backup destination' do
    home = '/root'
    access_key = 'access_key'
    secret_key = 'secret'
    user = 'root'
    group = 'root'

    before do
      chef_run.node.set['backup_restore']['destinations']['enabled'] = %w(s3)
      chef_run.node.set['backup_restore']['destinations']['s3'] = {
        bucket: 's3bucket',
        access_key_id: access_key,
        secret_access_key: secret_key,
        region: 'us-east-1',
        prefix: '/backup'
      }
      chef_run.node.set['backup_restore']['home'] = home
      chef_run.node.set['backup_restore']['user'] = user
      chef_run.node.set['backup_restore']['group'] = group
      chef_run.converge(described_recipe)
    end

    describe 'use proxy' do
      it 'create s3 config' do
        proxy_host = '172.0.0.250'
        proxy_port = '8080'
        chef_run.node.set['backup_restore']['config']['use_proxy'] = true
        chef_run.node.set['backup_restore']['config']['proxy_host'] = proxy_host
        chef_run.node.set['backup_restore']['config']['proxy_port'] = proxy_port
        chef_run.converge(described_recipe)
        expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
          :s3cfg,
          :create,
          "#{home}/.s3cfg"
        ).with(
          access_key: access_key,
          secret_key: secret_key,
          owner: user,
          group: group,
          install_s3cmd: false,
          config: {
            'proxy_host' => proxy_host,
            'proxy_port' =>  proxy_port,
            'use_https' => false
          }
        )
      end
    end
    describe 'not use proxy' do
      it 'create s3 config that does not included proxy settings' do
        chef_run.node.set['backup_restore']['config']['use_proxy'] = false
        chef_run.converge(described_recipe)
        expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
          :s3cfg,
          :create,
          "#{home}/.s3cfg"
        ).with(
          access_key: access_key,
          secret_key: secret_key,
          owner: user,
          group: group,
          install_s3cmd: false,
          config: {}
        )
      end
    end
  end

  it 'create log directory' do
    log_dir = '/var/log/backup'
    owner = 'root'
    group = 'root'
    chef_run.node.set['backup_restore']['log_dir'] = log_dir
    chef_run.node.set['backup_restore']['user'] = owner
    chef_run.node.set['backup_restore']['group'] = group
    chef_run.converge(described_recipe)

    expect(chef_run).to create_directory(log_dir).with(
      owner: owner,
      group: group
    )
  end

  describe 'postgresql is enabled as backup source' do
    it 'include configure_postgresql recipe' do
      chef_run.node.set['backup_restore']['sources']['enabled'] = %w(postgresql)
      chef_run.converge(described_recipe)
      expect(chef_run).to include_recipe('backup_restore::configure_postgresql')
    end
  end
end
