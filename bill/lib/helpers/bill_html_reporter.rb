# encoding: UTF-8
# filename: bill/lib/helpers/bill_html_reporter.rb

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
  @html_report.syswrite((File.file?(Dir.pwd+'/bill/lib/helpers/html_fomat/html_start.txt') ? IO.read(Dir.pwd+'/ios/lib/helpers/html_fomat/html_start.txt') : "").force_encoding("UTF-8"))
end

def set_htmlReport(testcase_hash)
  begin
    File.open(@html_save_dir+"/自动化测试报告(YAML).yaml", (File::WRONLY | File::APPEND | File::CREAT)){|f| YAML.dump(testcase_hash, f)}
    @PersonFeatures=0
    @BillFeatures=0
    @ControlFeatures=0
    @PersonFeaturesPass=0
    @BillFeaturesPass=0
    @ControlFeaturesPass=0
    testcase_hash['features_suite'].each do |n|
      @PersonFeatures+=1 if n['features_suite_name']=='PersonFeatures'
      @BillFeatures+=1 if n['features_suite_name']=='BillFeatures'
      @ControlFeatures+=1 if n['features_suite_name']=='ControlFeatures'
      @PersonFeaturesPass+=1 if n['features_suite_name']=='PersonFeatures' and n['feature_ruslt']=='passed'
      @BillFeaturesPass+=1 if n['features_suite_name']=='BillFeatures' and n['feature_ruslt']=='passed'
      @ControlFeaturesPass+=1 if n['features_suite_name']=='ControlFeatures' and n['feature_ruslt']=='passed'
    end
    content='<DIV id=content1><TABLE cellSpacing=0 cellPadding=0><TBODY><TH>总列</TH><TH>个人业务</TH><TH>资费管理</TH><TH>信用控制</TH>'
    content+="<TR><TD>运行脚本数</TD><TD>#{@PersonFeatures}</TD><TD>#{@BillFeatures}</TD><TD>#{@ControlFeatures}</TD></TR>"
    content+="<TR><TD>通过脚本数</TD><TD>#{@PersonFeaturesPass}</TD><TD>#{@BillFeaturesPass}</TD><TD>#{@ControlFeaturesPass}</TD></TR>"
    content+="<TR><TD>错误脚本数</TD><TD>#{@PersonFeatures-@PersonFeaturesPass}</TD><TD>#{@BillFeatures-@BillFeaturesPass}</TD><TD>#{@ControlFeatures-@ControlFeaturesPass}</TD></TR>"
    content+="<TR><TD>通过率</TD><TD>#{sprintf("%.2f",(@PersonFeaturesPass*100).to_f/@PersonFeatures).to_s+"%"}</TD><TD>#{sprintf("%.2f",(@BillFeaturesPass*100).to_f/@BillFeatures).to_s+"%"}</TD><TD>#{sprintf("%.2f",(@ControlFeaturesPass*100).to_f/@ControlFeatures).to_s+"%"}</TD></TR>"
    content+='</TBODY></TABLE>'
    content+='<TABLE cellSpacing=0 cellPadding=0><TBODY><TH>feature_name_desc</TH><TH>feature_name</TH><TH>status</TH>'
    testcase_hash['features_suite'].each do |n|
      content+="<TR><TD #{if n['feature_ruslt'] =='passed' then 'style="COLOR: #00ff00"' else 'style="COLOR: #eb0000"' end;}>#{unicode_utf8(n['feature_name_desc'])}</TD><TD #{if n['feature_ruslt'] =='passed' then 'style="COLOR: #00ff00"' else 'style="COLOR: #eb0000"' end;}>#{n['feature_name']}</TD><TD #{if n['feature_ruslt'] =='passed' then 'style="COLOR: #00ff00"' else 'style="COLOR: #eb0000"' end;}>#{n['feature_ruslt']}</TD></TR>"
    end
    content+='</TBODY></TABLE>'
    content+='<TABLE cellSpacing=0 cellPadding=0><TBODY><TH>step_desc</TH><TH>step_ruslt</TH>'
    testcase_hash['features_suite'].each do |n|
      content+="<TR><TD #{if n['feature_ruslt'] =='passed' then 'style="COLOR: #00ff00"' else 'style="COLOR: #eb0000"' end;}>#{n['feature_name_desc']}</TD><TD> </TD></TR>"
      n['feature_steps'].each do |m|
        content+="<TR><TD>#{m['step_desc']}</TD><TD #{if m['step_ruslt'] =='passed' then 'style="COLOR: #00ff00"' else 'style="COLOR: #eb0000"' end;}>#{if m['step_ruslt'] =='passed' then m['step_ruslt'] else 'skiped' end;} </TD></TR>"
        content+="<TR><TD><img style=\"height:100px;border:1px solid blue;width:auto;margin-right:200px;\"  src=\"#{m['screenshort_url']}\" /></TD><TD> </TD></TR>" if m['screenshort_url']!=nil

        if m['step_print']!=nil
          content+="<TR><TD>"
          @superscript=0
          for subscript in 0..m['step_print'].to_s.length do
            if subscript!=0 and subscript%80==0
              content+="#{m['step_print'].to_s[@superscript..subscript]}<br>"
              @superscript=subscript+1
            end
          end
          content+=m['step_print'].to_s[@superscript..m['step_print'].to_s.length]
          content+="</TD><TD>step_print</TD></TR>"
        end
        content+="<TR><TD>#{m['control_data']}</TD><TD>test_data</TD></TR>" if m['control_data']!=nil
      end
      content+="<TR><TD>#{n['error_info']}</TD><TD>step_info</TD></TR>" if n['error_info']!=nil
      content+="<TR><TD></TD><TD></TD></TR>"
    end
    content+='</TBODY></TABLE></DIV>'
    @html_report.syswrite(content)
  rescue => ex
    $LOG.error "#{ex}".red
    raise
  end
end

def end_htmlReport()
  @html_report.syswrite((File.file?(Dir.pwd+'/bill/lib/helpers/html_fomat/html_end.txt') ? IO.read(Dir.pwd+'/ios/lib/helpers/html_fomat/html_end.txt') : "").force_encoding("UTF-8"))
end

