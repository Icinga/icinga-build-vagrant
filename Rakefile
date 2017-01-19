task default: %w[deploy]

desc 'Deploy Puppet code via r10k'
task :deploy do
  require 'r10k/cli'
  require 'colored'
  here = Dir.pwd
  Dir.chdir('vagrant')
  R10K::CLI.command.run(%w(puppetfile install -v))
  Dir.chdir(here)
end

desc 'Clean deployed Puppet code'
task :clean do
  FileUtils.rm_rf('vagrant/modules/')
end
