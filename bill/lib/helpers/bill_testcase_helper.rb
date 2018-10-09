# encoding: UTF-8
# filename: bill/lib/helpers/bill_testcase_helper.rb

require_relative 'bill_utils'
require_relative 'bill_yaml_helper'
require_relative 'bill_csv_helper'

def exec_feature_step(step,feature,index=nil)
  """ execute feature step.
  """
  begin
    if step['control_script'] == 'screenshort'
      step['screenshort_url']=screenshort
    elsif step['control_script'] ==nil or step['control_script'].to_s == "N/A"
      raise "control_script is nil!"
    else
      step_action = step['control_script']
      eval step_action
    end
  rescue
    # do not fail the testcase if the failed step is an optional step
    if step['control_recover'].to_s == "N/A" or step['control_recover'] == nil or step['control_recover'] == ""
      begin
        raise
      rescue
        step['screenshort_url']=screenshort
        raise
      end
    end
      begin
       if step['control_recover'] == "Redo_Step"
         eval step['control_script']
         $LOG.info "control_recover"+step['control_recover'].green
       elsif step['control_recover'] == "Avoid_Error"
       elsif step['control_recover'].nil? or step['control_recover'].to_s == "N/A"
         raise
       else
         begin
         eval step['control_recover']
         $LOG.info "control_recover"+step['control_recover'].green
         rescue
           raise
         end
       end
      rescue
        step['screenshort_url']=screenshort
        raise
      end
    end
end

def verify_step_expectation(expectation)
  """ verify if step executed as expectation.
  """
  eval expectation
end

def run_testcase(testcase_hash)
  testcase_name = testcase_hash['testcase_name']
  $LOG.info "======= start to run test testcase: #{testcase_name} =======".yellow
  features_suite = testcase_hash['features_suite']
  #require 'win32ole'
  #require 'Watir'
  @naboss_page
  @funtion_result
  features_suite.each do |feature|
    $LOG.info "B------ Start to run feature: #{feature['feature_name']}".blue
    $LOG.info "feature: #{feature}"
    step_action_desc = ""
    begin
      feature['feature_steps'].each_with_index do |step, index|
        $LOG.info "step_#{index+1}: #{step['step_desc']}".cyan
        control_script = step['control_script']
        expectation = step['expectation']
        step['step_index'] = index
        step_action_desc = "#{control_script}"

        exec_feature_step(step,feature,index)
        step['control_data'] = eval(step['control_data']) if step['control_data'] != nil
        # check if feature step executed successfully
        if expectation
          raise "the script :\'"+expectation+"\' should == ture" unless eval(expectation)==true
        end
        step_action_desc += "    ...    ✓"
        step['step_ruslt']='passed'
        $LOG.info step_action_desc.green
        step_action_desc = ""
        feature['feature_ruslt']='passed'
      end
    rescue => ex
      eval readYaml('RecoverSteps.yml','RecoverSteps|normal_recover','control_script')
      feature['error_info']=ex
      feature['feature_ruslt']='failed'
      step_action_desc += "    ...    ✖"
      $LOG.error step_action_desc.red
      $LOG.error "#{ex}".red
    end

    $LOG.info "E------ #{feature['feature_name']}\n".blue
  end # features_suite
  $LOG.info "============ all features have been executed. ============".yellow

  set_htmlReport testcase_hash
  end_htmlReport()
  testcase_hash
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