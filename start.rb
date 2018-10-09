# encoding: UTF-8
# filename: start.rb

require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: start.rb [options]"
  #应用路径
  opts.on("-p <value>", "--app_path", "Specify app path") do |v|
    options[:test_path] = v
  end

  #测试类型
  opts.on("-s <value>", "--test_type", "Specify test_type, ios/android/web/api") do |v|
    test_type = v.downcase
    unless ["ios", "android", "web", "api"].include? test_type
      raise ArgumentError, "test_type should only be ios/android/web/api!"
    end
    options[:test_type] = test_type
  end

  #app类型
  opts.on("-t <value>", "--app_type", "Specify app type, ios or android") do |v|
    app_type = v.downcase
    unless ["ios", "android"].include? app_type
      raise ArgumentError, "app_type should only be ios or android!"
    end
    options[:test_type] = app_type
  end

  #用例路径
  options[:testcase_file] = "*.yml"
  opts.on("-f <value>", "--testcase_file", "Specify testcase file(s)") do |file|
    file.downcase!
    file = "*.yml" if file == "*.yaml"
    options[:testcase_file] = file
  end

  options[:output_folder] = File.join(Dir.pwd, "results")
  opts.on("-d <value>", "--output_folder", "Specify output folder") do |v|
    options[:output_folder] = v
  end

  options[:convert_type] = "yaml2csv"
  opts.on("-c <value>", "--convert_type", "Specify testcase converter, yaml2csv or csv2yaml") do |v|
    options[:convert_type] = v
  end

  options[:output_color] = true
  opts.on("--disable_output_color", "Disable output color") do
    options[:output_color] = false
  end

end.parse!



if options[:testcase_file] && options[:test_type]=="web"
  require_relative 'web/lib/requires'
  require_relative 'web/lib/runner_web'
  initialize_project_environment options
  OUTPUT_WITH_COLOR = options[:output_color]
  run_test(options)
elsif options[:testcase_file] && options[:test_type]=="api"
  require_relative 'api/lib/requires'
  require_relative 'api/lib/runner_api'
  initialize_project_environment options
  OUTPUT_WITH_COLOR = options[:output_color]
  run_test(options)
elsif options[:testcase_file] && options[:test_type]=="ios"
  require_relative 'ios/lib/requires'
  require_relative 'ios/lib/runner_web'
  initialize_project_environment options
  OUTPUT_WITH_COLOR = options[:output_color]
  run_test(options)
elsif options[:testcase_file] && options[:test_type]=="android"
  require_relative 'android/lib/requires'
  require_relative 'android/lib/runner_android'
  initialize_project_environment options
  OUTPUT_WITH_COLOR = options[:output_color]
  run_test(options)
elsif options[:convert_type] && File.file?(options[:testcase_file])
  require_relative 'web/lib/requires'
  require_relative 'web/lib/runner_web'
  initialize_project_environment options
  convert_yaml_to_csv(options[:testcase_file]) if options[:convert_type] == "yaml2csv"
else
  raise ArgumentError
end
