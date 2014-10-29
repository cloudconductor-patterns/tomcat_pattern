require_relative '../spec_helper'

describe 'backup_restore::fetch_s3' do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    )do |node|
      node.set['backup_restore']['destinations']['s3'] = {
        bucket: 's3bucket',
        access_key_id: 'access_key_id',
        secret_access_key: 'secret_access_key',
        region: 'us-east-1',
        prefix: '/backup'
      }
      node.set['backup_restore']['restore']['target_sources'] = ['mysql']
    end
    runner.converge(described_recipe)
  end

  tmp_dir = '/tmp/backup/restore'
  backup_name = 'directory_full'

  it 'download backup files' do
    allow(::File).to receive(:exist?).and_call_original
    allow(::File).to receive(:exist?).with("#{tmp_dir}/#{backup_name}.tar").and_return(true)
    expect_any_instance_of(Chef::Recipe).to receive(:`).and_return('s3://s3bucket/backup/directory_full/2014.10.01.00.00.00')

    expect(chef_run).to run_bash('download_backup_files').with(
      code: "/usr/bin/s3cmd get -r 's3://s3bucket/backup/directory_full/2014.10.01.00.00.00' #{tmp_dir}"
    )
  end
end
