# encoding: UTF-8
# filename: bill/lib/helpers/bill_config_helper.rb

class Hash
  def method_missing(method, *opts)
    self[method.to_s] || super
  end
end

module Kernel
  def config
    YAML.load_file File.join(Dir.pwd+'/bill', 'config.yml')
  end
end
