# filename: api/lib/helpers/api_config_helper.rb
require 'yaml'

class Hash
  def method_missing(method, *opts)
    self[method.to_s] || super
  end
end

module Kernel
  def config
    YAML.load_file File.join(Dir.pwd+'/api', 'config.yml')
  end
end
