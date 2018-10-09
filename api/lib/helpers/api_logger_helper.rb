# filename: api/lib/helpers/api_logger_helper.rb

require 'logger'

def initialize_logger(log_save_dir)
  log_save_path = File.join(log_save_dir, "AutoTester.log")
  $LOG = Logger.new("#{log_save_path}")
  $LOG.level = Logger::INFO

  $LOG.formatter = proc do |severity, datetime, progname, msg|
    datetime_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{datetime_format}] #{severity}: #{msg}\n"
  end
  $LOG.info "Logs directory: #{log_save_dir}".green
end

