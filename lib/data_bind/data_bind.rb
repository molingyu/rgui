module DataBind
  def self.single_bind(object1, attr1, object2, attr2, &proc)
    object1.instance_eval do
      @_setters = {} unless @_setters
      @_setters[attr1] = [] unless @_setters[attr1]
      @_setters[attr1] << proc { |value, original| object2.send("#{attr2}=".to_sym, value, original) }
      old = method("#{attr1}=".to_sym)
      define_singleton_method("#{attr1}=".to_sym) do |value, original|
        return if method(attr1)[] == original
        old[value]
        original = value
        value = proc[value] if proc
        @_setters[attr1].each{ |setter| setter[value, original]  }
      end
    end
  end

  def self.bind(object1, attr1, object2, attr2)
    single_bind(object1, attr1, object2, attr2)
    single_bind(object2, attr2, object1, attr1)
  end
end