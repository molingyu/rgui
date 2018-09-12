require 'yard'
require './lib/version'

YARD::Rake::YardocTask.new(:api_doc) do |t|
  t.files   = %w(lib/**/*.rb README.md LICENSE)
  t.options += ['--title', "RGUI #{RGUI::VERSION} Documentation"]
end

desc "pack scripts"
task :pack do
  require_relative './script_pack'
  FileUtils.mkdir_p('dist') unless File.exists?('dist')
  rm_pack.pack({
                   source: './lib/rgui.rb',
                   excludes: ['rgss/rgss_base.rb'],
                   output:'dist/rgui.rb'
               })
end

desc "clean project"
task :clean do
  %x[rm -rf ./dist/*]
end

task :doc_server do
  %x[docsify serve docs]
end

desc "run example"
task :run do
  %x[./example/Game.exe]
end

desc "start rgui"
task start: [:clean, :pack, :run]


task default: [:start]
