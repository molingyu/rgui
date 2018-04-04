class View
  
  def initialize
    @contents ||= []
  end

  def add_child(o)
    @contents.push(o)
  end

  def add_child_at(o,id)
    @contents.insert(id,o)
  end

  def remove_child(o)
    @contents.delete_if {|x| x = o }
  end

  def remove_child_at(id)
    @contents.delete_at(id)
  end

  def update
    @contents.each{|o| o.update} unless @contents.empty?
  end

  def dispose
    @contents.each{|o| o.dispose} unless @contents.empty?
  end

end
