# filename: web/lib/helpers/web_html_reporter.rb

def unicode_utf8(unicode_string)
  unicode_string.gsub(/\\u\w{4}/) do |s|
    str = s.sub(/\\u/, "").hex.to_s(2)
    if str.length < 8
      CGI.unescape(str.to_i(2).to_s(16).insert(0, "%"))
    else
      arr = str.reverse.scan(/\w{0,6}/).reverse.select{|a| a != ""}.map{|b| b.reverse}
      hex = lambda do |s|
        (arr.first == s ? "1" * arr.length + "0" * (8 - arr.length - s.length) + s : "10" + s).to_i(2).to_s(16).insert(0, "%")
      end
      CGI.unescape(arr.map(&hex).join)
    end
  end
end

def initialize_htmlReport(html_save_dir)
  @html_save_dir=html_save_dir
  File.open(html_save_dir+"/自动化测试报告(HTML).html", (File::WRONLY | File::APPEND | File::CREAT))
  @html_report=File.new(html_save_dir+"/自动化测试报告(HTML).html","r+")
  @html_report.syswrite((File.file?(Dir.pwd+'/web/lib/helpers/html_fomat/html_start.txt') ? IO.read(Dir.pwd+'/ios/lib/helpers/html_fomat/html_start.txt') : "").force_encoding("UTF-8"))
end

def set_htmlReport(testcase_hash)
  File.open(@html_save_dir+"/自动化测试报告(YAML).yaml", (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(testcase_hash, f)}
  @PersonFeatures=0
  @GroupFeatures=0
  @AcountFeatures=0
  @PersonFeaturesPass=0
  @GroupFeaturesPass=0
  @AcountFeaturesPass=0
  testcase_hash['features_suite'].each do |n|
    @PersonFeatures+=1 if n['features_suite_name']=='PersonFeatures'
    @GroupFeatures+=1 if n['features_suite_name']=='GroupFeatures'
    @AcountFeatures+=1 if n['features_suite_name']=='AcountFeatures'
    @PersonFeaturesPass+=1 if n['features_suite_name']=='PersonFeatures' and n['features_suite_name']=='feature_ruslt'
    @GroupFeaturesPass+=1 if n['features_suite_name']=='GroupFeatures' and n['features_suite_name']=='feature_ruslt'
    @AcountFeaturesPass+=1 if n['features_suite_name']=='AcountFeatures' and n['features_suite_name']=='feature_ruslt'
  end
  content='<DIV id=content1><TABLE cellSpacing=0 cellPadding=0><TBODY><TH>总列</TH><TH>个人业务</TH><TH>集团业务</TH><TH>账务管理</TH>'
  content+="<TR><TD>运行脚本数</TD><TD>#{@PersonFeatures}</TD><TD>#{@GroupFeatures}</TD><TD>#{@AcountFeatures}</TD></TR>"
  content+="<TR><TD>通过脚本数</TD><TD>#{@PersonFeaturesPass}</TD><TD>#{@GroupFeaturesPass}</TD><TD>#{@AcountFeaturesPass}</TD></TR>"
  content+="<TR><TD>错误脚本数</TD><TD>#{@PersonFeatures-@PersonFeaturesPass}</TD><TD>#{@GroupFeatures-@GroupFeaturesPass}</TD><TD>#{@AcountFeatures-@AcountFeaturesPass}</TD></TR>"
  content+="<TR><TD>通过率</TD><TD>#{sprintf("%.2f",@PersonFeaturesPass.to_f/@PersonFeatures).to_s+"%"}</TD><TD>#{sprintf("%.2f",@GroupFeaturesPass.to_f/@GroupFeatures).to_s+"%"}</TD><TD>#{sprintf("%.2f",@AcountFeaturesPass.to_f/@AcountFeatures).to_s+"%"}</TD></TR>"
  content+='</TBODY></TABLE>'
  content+='<TABLE cellSpacing=0 cellPadding=0><TBODY><TH>feature_name_desc</TH><TH>feature_name</TH><TH>status</TH>'
  testcase_hash['features_suite'].each do |n|
    content+="<TR><TD>#{unicode_utf8(n['feature_name_desc'])}</TD><TD>#{n['feature_name']}</TD><TD>#{n['feature_ruslt']}</TD></TR>"
  end
  content+='</TBODY></TABLE>'
  content+='<TABLE cellSpacing=0 cellPadding=0><TBODY><TH>step_desc</TH><TH>step_ruslt</TH>'
  testcase_hash['features_suite'].each do |n|
    content+="<TR><TD>#{n['feature_name_desc']}</TD><TD> </TD></TR>"
    n['feature_steps'].each do |m|
      content+="<TR><TD>#{m['step_desc']}</TD><TD>#{m['step_ruslt']} </TD></TR>"
      content+="<TR><TD>#{m['error_info']}</TD><TD>step_print</TD></TR>" if m['error_info']!=nil
    end
    content+="<TR><TD>#{n['error_info']}</TD><TD>step_info</TD></TR>" if n['error_info']!=nil
    content+="<TR><TD></TD><TD></TD></TR>"
  end
  content+='</TBODY></TABLE></DIV>'
  @html_report.syswrite(content)
end

def end_htmlReport()
  @html_report.syswrite((File.file?(Dir.pwd+'/web/lib/helpers/html_fomat/html_end.txt') ? IO.read(Dir.pwd+'/ios/lib/helpers/html_fomat/html_end.txt') : "").force_encoding("UTF-8"))
end
