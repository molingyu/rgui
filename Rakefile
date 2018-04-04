require 'bundler/gem_tasks'
require 'yard'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = %w(lib/**/*.rb README.md LICENSE)
  t.options += ['--title', "RGUI #{RGUI::VERSION} Documentation"]
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  nil # noop
end

desc "pack scripts"
task :pack do
  require_relative './script_pack'
  FileUtils.mkdir_p('dist') unless File.exists?('dist')
  pack('lib/rgui.rb', 'dist/rgui.rb')
end



task default: [:spec]
