require 'fileutils'
require 'zlib'

module RmPack
  class RmPack
    class << self

      # @return [Array<Proc>]
      attr_reader :loaders

      def use(loader)
        @loaders = [] unless @loaders
        @loaders << loader
      end

    end

    attr_reader :excludes
    attr_reader :source
    attr_reader :output
    attr_reader :runtime

    def initialize
      @visited = {}
      @cont = []
      @count = 0
      @files = {}
      @current_loaders = []
      @runtime = nil
    end

    def get_requires
      until @cont.empty?
        visit(@cont.shift, @visited, @cont)
      end
    end

    def get_file_name(file)
      "\n\n# File #{file.gsub(Dir::getwd + '/', '')}\n\n"
    end

    def get_file(file)
      @files[file]
          .gsub("# encoding:utf-8\n", '')
          .strip
    end

    def init_loaders
      RmPack.loaders.each { |loader| @current_loaders.push(loader.new(self)) }
    end

    def create_file
      FileUtils.mkdir_p(File.dirname(@output))
      File.open(@output, 'w')
    end

    def pack(conf)
      @source = File.expand_path(conf[:source], File.dirname(__FILE__))
      @excludes = conf[:excludes] || []
      @output = conf[:output] || './out.rb'
      @excludes.map!{|exclude| File.expand_path(exclude, File.dirname(@source)) }
      @runtime = conf[:runtime] || :default
      init_loaders
      @cont << @source
      get_requires
      list = reorder(@source, @visited[@source])
      puts "output: #{@output}"
      @output.include?('.rvdata2') ? out_rvdata2(list) : out_rb(list)
      puts "Finish! #{@count} files."
    end

    def get_build_attr
      "# build date:#{Time.now}\n# build runtime:#{@runtime}\n"
    end

    def out_rvdata2(list, mode = 0)
      script = []
      if mode == 0
        list.each do |file|
          file_str = get_file(file)
          next '' if file_str == ''
          @count += 1
          puts file
          script << [@count, get_file_name(file).strip.match(/# File (.*).rb/)[1], Zlib::Deflate.deflate(get_file(file).strip)]
        end
      end
      File.open(@output, "wb") { |f|
        Marshal.dump(script, f)
      }
    end

    def out_rb(list)
      create_file.write("# encoding:utf-8\n" + get_build_attr + list.map { |file|
        file_str = get_file(file)
        next '' if file_str == ''
        @count += 1
        puts file
        get_file_name(file) + file_str
      }.reduce(:concat).strip)
    end

    # @param [String] file
    # @param [Hash] visited
    # @param [Array] cont
    def visit(file, visited, cont)
      return if visited.include? file
      visited[file] = []
      File.open(file) do |f|
        @files[file] = f.readlines.map { |str|
          delete = false
          @current_loaders.each do |loader|
            if loader.match(str, f)
              depends = loader.file
              next delete = true if depends == file
              cont << depends unless cont.include? depends
              visited[file] << depends
            end
            delete =  delete || loader.delete
          end
          delete ? '' : str
        }.reduce(:concat)
      end
    end

    # @param [String] file
    # @param [Array<String>] dependency
    def reorder(file, dependency)
      return [file] if dependency == [] || dependency == nil
      dependency.map {|dep| reorder(dep, @visited[dep]) }.push(file).flatten.uniq
    end
  end

  class RequireRelativeLoader

    attr_reader :file
    attr_reader :delete

    def initialize(conf)
      @excludes = conf.excludes
      @runtime = conf.runtime
      @file = ''
      @match_exp = /require_relative[^\n]*/
      @file_exp = /require_relative\s*'([^']*)'/
      @mark_exp = /require_relative\s*'[^']*'\s*\# delete\s/
      @rgd_exp = /require_relative\s*'[^']*'\s*\# runtime=(rgm;)?rgd(;rgm)?\s/
      @rgm_exp = /require_relative\s*'[^']*'\s*\# runtime=(rgd;)?rgm(;rgd)?\s/
      @delete = true
    end

    def add_suffix(str)
      return str + '.rb' unless str.end_with? 'rb'
      str
    end

    def match(str, f)
      @delete = false
      return false if str !~ @match_exp
      @delete = true
      return false if str =~ @mark_exp
      return false if str !~ @file_exp
      match_str = $1
      filename = ''
      case @runtime
      when :default
        filename = add_suffix(match_str)
      when :rgm
        filename = add_suffix(match_str + (str =~ @rgm_exp ? '_rgm' : ''))
      when :rgd
        filename = add_suffix(match_str + (str =~ @rgd_exp ? '_rgd' : ''))
      else
        filename = add_suffix(match_str)
      end
      @file = File.expand_path(filename, File.dirname(f))
      return false if @excludes.include? @file
      @file
    end

  end

  RmPack.use(RequireRelativeLoader)

end

def rm_pack
  RmPack::RmPack.new
end