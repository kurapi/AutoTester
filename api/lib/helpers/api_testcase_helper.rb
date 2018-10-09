# filename: api/lib/helpers/api_testcase_helper.rb

require_relative 'api_utils'
require_relative 'api_yaml_helper'
require_relative 'api_csv_helper'

def exec_feature_step(step)
  begin
    step['request_message']=eval(step['request_message'])
    $api_driver.get_request_message step['request_message']
    step['sub_param'].each do |n,m|
      $api_driver.gusb_request_message n,m
    end
    xml_str=$api_driver.start_driver
    $LOG.info "step_xml_str: ".cyan
    if xml_str[step['expectation']]==nil
      step['step_ruslt']='failed'
      step['error_info']= "the result should be 【#{step['expectation']}】,but get: #{xml_str}"
    end
  rescue
    raise
  end
end

def verify_step_expectation(expectation)
  eval expectation
end

def run_testcase(testcase_hash)
  $api_driver = ApiDriver.new config.TestEnvParam.URL
  testcase_name = testcase_hash['testcase_name']
  $LOG.info "======= start to run test testcase: #{testcase_name} =======".yellow
  features_suite = testcase_hash['features_suite']
  features_suite.each do |feature|
    $LOG.info "B------ Start to run feature: #{feature['feature_name']}".blue
    $LOG.info "feature: #{feature}"
    step_action_desc = ""
    begin
      feature['feature_steps'].each_with_index do |step, index|
        $LOG.info "step_#{index+1}: #{step['step_desc']}".cyan
        step['step_index'] = index
        exec_feature_step(step)
        step_action_desc += "    ...    ✓"
        if step['step_ruslt']!='failed'
          step['step_ruslt']='passed'
        elsif step['step_ruslt']=='failed'
          feature['feature_ruslt']='failed'
        end
      end
    rescue => ex
      feature['error_info']=ex
      step_action_desc += "    ...    ✖"
      $LOG.error step_action_desc.red
      $LOG.error "#{ex}".red
    end
    feature['feature_ruslt']='passed' if feature['feature_ruslt']!='failed'
    $LOG.info "E------ #{feature['feature_name']}\n".blue
  end # features_suite
  $LOG.info "============ all features have been executed. ============".yellow
  set_htmlReport testcase_hash
  end_htmlReport()
end

def parse_testcase_file(testcase_file)
  if testcase_file.end_with? ".csv"
    testcase_hash = load_testcase_csv_file(testcase_file)
  elsif testcase_file.end_with? ".yml"
    testcase_hash = load_testcase_yaml_file(testcase_file)
  elsif testcase_file.end_with? ".yaml"
    testcase_hash = load_testcase_yaml_file(testcase_file)
  else
    raise "Only support yaml and csv format!"
  end
  testcase_hash
end

def run_all_testcases(testcase_files)
  #Dir.glob(testcase_files) do |testcase_file|
    testcase_file = File.expand_path(testcase_files)
    testcase_hash = parse_testcase_file(testcase_files)
    $LOG.info "testcase_hash: #{testcase_hash}"
   # next if testcase_hash.empty? || testcase_hash['features_suite'].empty?
    # $appium_driver.alert_accept
    run_testcase(testcase_hash)
  #end
end
#yihahahhahahhahaha