require 'spec_helper'

# packages
%w{nginx git gcc gcc-c++ make openssl-devel zlib-devel readline-devel golang fuse}.each do |pkg|
  describe package(pkg), :if => os[:family] == 'amazon' do
    it { should be_installed }
  end
end

# rbenv
describe command('source /etc/profile.d/rbenv.sh; which rbenv') do
  let(:disable_sudo) { true }
  its(:exit_status) { should eq 0 }
end

# rbenv.sh
describe file('/etc/profile.d/rbenv.sh') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 644 }
  its(:content) { should match /^export RBENV_ROOT="\/opt\/rbenv"$/ }
  its(:content) { should match /^export PATH="\$\{RBENV_ROOT\}\/bin:\$\{PATH\}"$/ }
  its(:content) { should match /^eval "\$\(rbenv init -\)"$/ }
end

# ruby-build
rbenv_plugin_dir = "/opt/rbenv/plugins"
describe file("#{rbenv_plugin_dir}") do
  it { should be_directory }
  it { should be_owned_by 'ec2-user' }
  it { should be_grouped_into 'ec2-user' }
  it { should be_mode 775 }
end

describe file("#{rbenv_plugin_dir}/ruby-build/.git/") do
  it { should be_directory }
  it { should be_owned_by 'ec2-user' }
  it { should be_grouped_into 'ec2-user' }
  it { should be_mode 775 }
end

# ruby
describe command("source /etc/profile.d/rbenv.sh; rbenv versions | grep 2.7.2") do
  let(:disable_sudo) { true }
  its(:stdout) { should match /2\.7\.2/ }
end

describe command("/etc/profile.d/rbenv.sh; rbenv global") do
  let(:disable_sudo) { true }
  its(:stdout) { should match /2\.7\.2/ }
end

# gems
%w{bundler rails}.each do |gem|
  describe package(gem) do
    let(:disable_sudo) { true }
    it { should be_installed.by('gem') }
  end
end

# nginx running
describe service('nginx'), :if => os[:family] == 'amazon' do
  it { should be_enabled }
  it { should be_running }
end

# port
%w{80 22}.each do |pt|
  describe port(pt) do
    it { should be_listening }
  end
end

# mysql
describe command('mysql --version') do
  let(:disable_sudo) { true }
  its(:stdout) { should match /mysql  Ver/ }
end

# goofys
# describe command('/opt/go/bin/goofys --version') do
#   its(:stdout) { should match /^goofys version .+$/ }
# end

describe command('date') do
  its(:stdout) { should match /JST/ }
end
