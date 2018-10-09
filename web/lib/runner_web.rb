# encoding: UTF-8
# filename: web/lib/runner_web.rb
require "pathname"

def run_test(options)
  #require 'rspec'
  #require "watir"
  #require 'win32/screenshot'
  testcase_file = options[:testcase_file]
    begin
      if File.exists? testcase_file
        testcase_files = testcase_file
      elsif Pathname.new(testcase_file).absolute?
        testcase_files = testcase_file
      elsif testcase_file.include? File::SEPARATOR
        testcase_files = File.join(Dir.pwd, "#{testcase_file}")
      else
        testcases_dir = File.join(Dir.pwd, test_type, 'testcases')
        testcase_files = File.join(testcases_dir, "#{testcase_file}")
      end
      run_all_testcases(testcase_files)
    rescue => ex
      $LOG.error "#{ex}".red
    ensure
      $LOG.info "\n#{'>'*60}===#{'<'*60}\n".yellow
    end
end
