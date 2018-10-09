# encoding: UTF-8
# filename: bill/lib/helpers/bill_converter_helper.rb

require_relative 'bill_yaml_helper'

def convert_yaml_to_csv(testcase_yaml_file_path)
  $LOG.info "Convert #{testcase_yaml_file_path} to CSV format test testcases.".green
  testcase_hash = load_testcase_yaml_file(testcase_yaml_file_path)
  features_suite = testcase_hash['features_suite']
  testcase_csv_file_name = File.basename(testcase_yaml_file_path, ".*") + ".xls"
  testcase_csv_file_path = File.expand_path(
    File.join(File.dirname(testcase_yaml_file_path), testcase_csv_file_name)
  )
  titles = ['feature_name','step_desc','control_script','data','expectation','control_recover','optional']
  puts features_suite
  require "spreadsheet/excel"
  Spreadsheet.client_encoding="utf-8"
  book=Spreadsheet::Workbook.new
  sheet1=book.create_worksheet :name => "test1"
  titles.each_index do |index|
    sheet1.row(0)[index]=titles[index]
  end
  row_index=1
  features_suite.each do |feature|
    feature_name = feature['feature_name']
    feature['feature_steps'].each do |step|
      line_content_list = Array.new
      line_content_list << feature_name
      titles[1..-1].each do |title|
        if title=="data" && step[title]!=nil
          line_content_list << eval("#{step[title]}")
        else
          line_content_list << "#{step[title]}"
        end
      end
      line_content_list.each_index do |index|
        sheet1.row(row_index)[index]=line_content_list[index]
      end
      row_index+=1
      feature_name = nil if feature_name
    end
  end

  book.write testcase_csv_file_path
  $LOG.info "CSV format test testcases generated: #{testcase_csv_file_path}".green
end
