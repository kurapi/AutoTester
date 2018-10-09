# filename: android/lib/helpers/android_html_reporter.rb

def initialize_htmlReport(html_save_dir)
  File.open(html_save_dir+"/自动化测试报告(HTML).html", (File::WRONLY | File::APPEND | File::CREAT))
  @html_report=File.new(html_save_dir+"/自动化测试报告(HTML).html","r+")
  puts Dir.pwd+'html_fomat/html_start.txt'
  @html_report.syswrite((File.file?(Dir.pwd+'/android/lib/helpers/html_fomat/html_start.txt') ? IO.read(Dir.pwd+'/android/lib/helpers/html_fomat/html_start.txt') : "").force_encoding("UTF-8"))
end

def set_htmlReport(content)
  @html_report.syswrite(content)
end

def end_htmlReport()
  @html_report.syswrite((File.file?(Dir.pwd+'/android/lib/helpers/html_fomat/html_end.txt') ? IO.read(Dir.pwd+'/android/lib/helpers/html_fomat/html_end.txt') : "").force_encoding("UTF-8"))
end

