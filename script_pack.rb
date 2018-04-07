require 'fileutils'

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

    def initialize
      @visited = {}
      @cont = []
      @count = 0
      @files = {}
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
      RmPack.loaders.map! { |loader| loader.new(self) }
    end

    def create_file
      FileUtils.mkdir_p(File.dirname(@output))
      File.open(@output, 'w')
    end

    def pack(conf)
      @source = conf[:source]
      @excludes = conf[:excludes] || []
      @output = conf[:output] || './out.rb'
      @excludes.map!{|exclude| File.expand_path(exclude, File.dirname(@source)) }
      init_loaders
      @cont << @source
      get_requires
      file = create_file
      file.write "# encoding:utf-8\n" + reorder(@source, @visited[@source]).map { |f|
        file_str = get_file(f)
        next '' if file_str == ''
        @count += 1
        puts f
        get_file_name(f) + file_str
      }.reduce(:concat).strip.gsub('', '')
      puts "Finish! #{@count} files."
    end

    # @param [String] file
    # @param [Hash] visited
    # @param [Array] cont
    def visit(file, visited, cont)
      return if (visited.include? file)
      visited[file] = []
      File.open(file) do |f|
        @files[file] = f.readlines.map { |str|
          delete = false
          RmPack.loaders.each do |loader|
            if loader.match(str, f)
              depends = loader.file
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
      return [file] if dependency == []
      dependency.map {|dep| reorder(dep, @visited[dep]) }.push(file).flatten.uniq
    end
  end

  class RequireRelativeLoader

    attr_reader :file
    attr_reader :delete

    def initialize(conf)
      @excludes = conf.excludes
      @file = ''
      @match_exp = /require_relative[^\n]*/
      @file_exp = /require_relative\s*'([^']*)'/
      @mark_exp = /require_relative\s*'[^']*'\s*\#delete\s/
      @delete = true
    end

    def add_suffix(str)
      return str + '.rb' unless str.reverse =~ /^br\./
      str
    end

    def match(str, f)
      @delete = false
      return false if str !~ @match_exp
      @delete = true
      return false if str =~ @mark_exp
      return false if str !~ @file_exp
      @file = File.expand_path(add_suffix($1), File.dirname(f))
      return false if @excludes.include? @file
      @file
    end

  end

  RmPack.use(RequireRelativeLoader)

end

def rm_pack
  RmPack::RmPack.new
end