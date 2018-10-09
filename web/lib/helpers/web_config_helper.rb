# encoding: UTF-8
# filename: web/lib/helpers/web_config_helper.rb

class Hash
  def method_missing(method, *opts)
    self[method.to_s] || super
  end
end

module Kernel
  def config
    YAML.load_file File.join(Dir.pwd+'/web', 'config.yml')
  end
end
