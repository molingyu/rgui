# encoding:utf-8

module API

  @api_cache = {}

  def self.to_api(str)
    @api_cache[str.hash] = Win32API.new(*str.split('|')) unless @api_cache.include? str.hash
    @api_cache[str.hash]
  end

end