require 'bundler/gem_tasks'
require 'yard'
require 'pp'

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = %w(lib/**/*.rb README.md LICENSE)
  t.options += ['--title', "RGUI #{RGUI::VERSION} Documentation"]
end

desc "pack scripts"
task :pack do
  require_relative './script_pack'
  FileUtils.mkdir_p('dist') unless File.exists?('dist')
  pack('lib/index.rb', 'dist/rgui.rb')
end



task default: [:pack]
