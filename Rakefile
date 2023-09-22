require 'yard'
require './lib/version'
require_relative './script_pack'

YARD::Rake::YardocTask.new(:api_doc) do |t|
  t.files   = %w(lib/**/*.rb README.md LICENSE)
  t.options += ['--title', "RGUI #{RGUI::VERSION} Documentation"]
end
env = {}

desc 'env default'
task :env_default do
  env[:runtime] = :default
end

desc 'env rgm'
task :env_rgm do
  env[:runtime] = :rgm
end

desc 'env rgd'
task :env_rgd do
  env[:runtime] = :rgd
end

desc "pack scripts"
task :pack do
  FileUtils.mkdir_p('dist') unless File.exists?('dist')
  rm_pack.pack({
                   source: './lib/rgui.rb',
                   excludes: ['rgss/rgss_base.rb'],
                   output:"dist/rgui.rb",
                   runtime: env[:runtime]
               })
end

desc "Runtime copy"
task :runtime_copy do
  Dir.mkdir('./dist/example')
  %x[cp -rf ./example/* ./dist/example/ ]
  %x[rm -rf ./dist/example/Data/Scripts/** ]
  case env[:runtime]
  when :default
    %x[cp -rf ./third_party/rgss3/* ./dist/example/ ]
  when :rgm
    %x[cp -rf ./third_party/rgm/* ./dist/example/ ]
  when :rgd
    %x[cp -rf ./third_party/rgd/* ./dist/example/ ]
  end
end

desc "build example"
task :build_example do
  rm_pack.pack({
                 source: './example/Data/Scripts/main.rb',
                 excludes: [],
                 output:"dist/example/Data/Scripts/main.rb",
                 runtime: env[:runtime]
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
  Dir.chdir('./dist/example') {
    %x[Game.exe console test]
  }
end

desc "start rgui(rgm)"
task start_rgm: [:clean, :env_rgm, :pack, :runtime_copy, :build_example, :run]

desc "start rgui(rgd)"
task start_rgd: [:clean, :env_rgd, :pack, :runtime_copy, :build_example, :run]

desc "start rgui"
task start: [:clean, :env_default, :pack, :runtime_copy, :build_example, :run]

task default: [:start]
