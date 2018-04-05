def pack(source, out)
  visited = {}

  cont = []

  cont << source

  def visit(file, visited, cont)
    return if (visited.include? file)
    visited[file] = []
    File.open(file) do |f|
      f.readlines.each do |s|
        if s.strip =~ /require_relative\s*'(.*)'/
          depends = $1
          unless visited.include? depends
            depends = File.expand_path(depends + '.rb', File.dirname(f))
            if depends !~ /.*\/rgss_base.rb/
              cont << depends unless cont.include? depends
              visited[file] << depends
            end
          end
        end
      end
    end
  end

  while not cont.empty?
    visit(cont.shift, visited, cont)
  end

  def reorder(file, dependency)
    return [file] if dependency[file] == []
    dependency[file].map {|dep| reorder(dep, dependency) }
               .reduce(:concat)
               .concat([file])
               .uniq
  end


  index = 0

  File.open(out, 'w').write reorder(source, visited).map {|file|
    next '' if file =~ /.*\/index.rb/
    index += 1
    puts file

    "\n\n# File #{file}\n\n" + File.open(file).read.gsub("# encoding:utf-8\n", '').strip
  }.map { |s|
    s.gsub(/require_relative\s*'(.*)'[\r\n]*/, '')
        .gsub(__FILE__[0, __FILE__.size - __FILE__.reverse.index('/')], '')

  }.reduce(:concat).strip

  puts "Finish! #{index} files."
end
