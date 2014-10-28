require_relative '../spec_helper'

describe 'backup_restore::restore_postgresql' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ) do |node|
      node.set['backup_restore']['sources']['postgresql'] = {
        db_user: 'root',
        db_password: '',
        data_dir: '/etc',
        version: '9.3.5',
        run_user: 'mysql',
        run_group: 'mysql'
      }
    end
    runner.converge(described_recipe)
  end

  tmp_dir = '/tmp/backup/restore'
  source = {
    db_user: 'root',
    db_password: '',
    data_dir: '/etc',
    version: '9.3.5',
    run_user: 'mysql',
    run_group: 'mysql'
  }
  backup_name = 'postgresql'
  backup_file = "#{tmp_dir}/#{backup_name}.tar"
  backup_dir = "#{tmp_dir}/#{backup_name}/PostgreSQL.bkpdir"

  it 'extract_full_backup' do
    allow(IO::File).to receive(:exist?).and_call_original
    allow(IO::File).to receive(:exist?).with(backup_file).and_return(true)
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(false)
    expect(chef_run).to run_bash('extract_full_backup').with(
      code: <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    tar -zxvf #{tmp_dir}/#{backup_name}/databases/PostgreSQL.tar.gz -C #{tmp_dir}/#{backup_name}
  EOF
    )
  end

  it "postgresql stop" do
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with(backup_dir).and_return(true)
    expect(chef_run).to stop_service("postgresql-#{source[:version]}")
  end

  it 'delete_old_data' do
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with(backup_dir).and_return(true)
    expect(chef_run).to run_bash('delete_old_data').with(
     code: "rm -rf #{source[:data_dir]}/*"
    )
  end

  it 'restore_backup' do
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with(backup_dir).and_return(true)
    allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}/PostgreSQL.bkpdir").and_return(true)
    expect(chef_run).to run_bash('restore_backup')
  end

  it 'postgresql start' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(backup_file).and_return(true)
    expect(chef_run).to start_service("postgresql-#{source[:version]}")
  end
end
