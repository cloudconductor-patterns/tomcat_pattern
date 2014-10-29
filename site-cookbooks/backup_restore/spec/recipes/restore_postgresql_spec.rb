require_relative '../spec_helper'

describe 'backup_restore::restore_postgresql' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  tmp_dir = '/tmp/backup/restore'
  source = {
    port: 5432,
    user: 'postgres',
    password: ''
  }
  backup_name = 'postgresql'
  backup_file = "#{tmp_dir}/#{backup_name}.tar"

  it 'extract_full_backup' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(backup_file).and_return(true)
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(false)
    expect(chef_run).to run_bash('extract_full_backup').with(
      code: <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    gunzip #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql.gz
  EOF
    )
  end

  postgresql_connection_info = {
    host: '127.0.0.1',
    port: source[:port] || 5432,
    username: source[:user],
    password: source[:password]
  }

  it 'run query for postgresql ' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql").and_return(true)
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database,
      :query,
      'postgres'
    ).with(
      connection: postgresql_connection_info
    )
  end
end
