# filename: android/lib/helpers/android_env_helper.rb

def initialize_project_environment(options)
  output_folder = options[:output_folder]

  unless File.exists?(output_folder)
    Dir.mkdir(output_folder)
  end

  time = Time.now.strftime "%Y-%m-%d_%H:%M:%S"
  results_dir = File.expand_path(File.join(output_folder, "#{time}"))
  unless File.exists?(results_dir)
    Dir.mkdir(results_dir)
    screenshots_dir = File.join(results_dir, "screenshots")
    Dir.mkdir(screenshots_dir)
    xmls_dir = File.join(results_dir, "xmls")
    Dir.mkdir(xmls_dir)
    errors_dir = File.join(results_dir, "errors")
    Dir.mkdir(errors_dir)
  end

  initialize_logger results_dir
  initialize_htmlReport results_dir
  options[:results_dir] = results_dir
  options[:screenshots_dir] = screenshots_dir
  options[:xmls_dir] = xmls_dir
  options[:errors_dir] = errors_dir

  $LOG.info "Results directory: #{results_dir}".green
  $LOG.info "Screenshots directory: #{screenshots_dir}".green
  $LOG.info "Errors directory: #{errors_dir}".green

end

def initialize_android_simulators(android_devices)
  devices_list = Array.new
  android_devices.each do |android_device|
    device = Hash.new
    device["deviceName"] = android_device[0]
    device["platformVersion"] = android_device[1]
    recreate_android_simulator android_device[0], android_device[1]
    devices_list << device
  end
  devices_list
end
