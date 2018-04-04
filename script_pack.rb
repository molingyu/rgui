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
            cont << depends unless cont.include? depends
            visited[file] << depends
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
     p file
    return dependency[file].map {|dep| reorder(dep, dependency) }
               .reduce(:concat)
               .concat([file])
               .uniq
  end

  index = 0
  File.open(out, 'w').write reorder(source, visited).map {|file|
    index += 1
    puts file
    "\n# File #{file}\n" + File.open(file).read
  }.map { |s|
    s.gsub(/require_relative\s*'(.*)'[\r\n]*/, "")
  }.reduce(:concat)

  puts "Finish! #{index} files."
end