# encoding: UTF-8
#使用示例
#yaml数据查询
# readYaml("a")   读取TestData.yaml文件的a序列并返回
def readYaml yamlFile,yamlKey,yamlData
  yamlModule = YAML.load(File.open(Dir.pwd+"/bill/steps/"+yamlFile))
  yamlKeyArr=yamlKey.split('|')
  yamlModuleStr='yamlModule'
  yamlKeyArr.each do |n|
    yamlModuleStr+="[\""+n+"\"]"
  end
  puts yamlModuleStr
  return eval yamlModuleStr+"[\"#{yamlData}\"]"
end

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

#使用示例
#yaml数据重写
# writeYaml("a","b")   往TestData.yaml文件的a序列写入b属性
def writeConfig yamlStr,yamlValue
  config_hash = YAML.load(File.open("#{Dir.pwd}\\bill\\"+'config.yml'))
  yamlArr=yamlStr.split('.')
  yamlEvalStr="config_hash"
  for i in 1..yamlArr.length-1
    yamlEvalStr+=('[\''+(yamlArr[i].to_s)+'\']')
  end
  yamlEvalStr+="=#{yamlValue.to_s}"
  eval yamlEvalStr
  File.open("#{Dir.pwd}\\bill\\"+'config.yml',"wb"){|f| YAML.dump(config_hash, f)}
end

#使用示例
#获取对于文本的服务号码
def getSerialNumber serialNumberStr
  @test=CRMBOSS.new
  #实例.serialNumSet(serial_number_str)   serial_number_str:传入的号码标识文本
  serial_number=@test.serialNumSet(serialNumberStr)
  return serial_number
end

def clickAlterAccetp naboss_page
  #专门写来点击ngboss生产环境退出浏览器用的，因为ie.close会弹出一个警告框。
  begin
    naboss_page.driver.switch_to.alert.accept
    return true
  rescue
    return false
  end
end

def clickAlterDismiss naboss_page
  #专门写来点击ngboss生产环境退出浏览器用的，因为ie.close会弹出一个警告框。
  begin
    naboss_page.driver.switch_to.alert.dismiss
    return true
  rescue
    return false
  end
end

def close_ie
  #调用Windows控件对象直接杀ie进程
  mgmt = WIN32OLE.connect ('winmgmts:\\\\.')
  processes=mgmt.instancesof("win32_process")
  processes.each do |process|
    if process.name =="iexplore.exe" then
      process.terminate()
    end
  end
end

def close_cmd
  # 调用Windows控件对象直接杀cmd进程
  mgmt1 = WIN32OLE.connect ('winmgmts:\\\\.')
  processes1=mgmt1.instancesof("win32_process")
  processes1.each do |process1|
    puts process1
    if process1.name =="cmd.exe" then
      process1.terminate()
    end
  end
end

def close_ruby
  # 调用Windows控件对象直接杀cmd进程
  mgmt1 = WIN32OLE.connect ('winmgmts:\\\\.')
  processes1=mgmt1.instancesof("win32_process")
  processes1.each do |process1|
    puts process1
    if process1.name =="ruby.exe" then
      process1.terminate()
    end
  end
end

#关闭弹出框 线程用
def check_for_popups

  @autoit = WIN32OLE.new('AutoItX3.Control')

  #线程循环

  loop do
    # 寻找同名称的弹出框，找到就点击  并结束线程
    ret = @autoit.WinWait("Windows Internet Explorer",'','1')

    if (ret==1) then
      @autoit.ControlClick("Windows Internet Explorer",'','1')
      Thread.kill($popup)
    end
  end

end

##关闭浏览器 线程用
def quit1
  @naboss_page.quit
end

def watirBrowserComplete browser
  Watir::Wait.until {puts @naboss_page.ready_state;@naboss_page.ready_state=="complete"}
end

def clickTradeSubmit naboss_page
  #专门写来点击ngboss生产环境退出浏览器用的，因为ie.close会弹出一个警告框。
  begin
    naboss_page.iframe(:id => /navframe/, :index => 1).button(:id=>"CSSUBMIT_BUTTON").when_present.click
    return true
  rescue
    return false
  end
end

class BillTestDriver
  #用例参数
  attr_accessor :testId, :testName, :strAcct_day, :strCycle_id, :currentOneDay, :dateCurrent, :today, :thistime, :dateMon
  #预期结果
  attr_accessor :free_code1, :redisStrs, :free_code2, :bILL_USER_TEST, :sms_expectation
  #用户参数
  attr_accessor :user_id, :serial_number, :acct_id, :senderChannle, :sqlDbStr, :channel, :feepolicyId, :resCode, :sms_str, :remind_state
  #测试参数
  attr_accessor :linuxIpAccount, :linuxIpAddr, :passWord, :inputDirPath, :bDS_Adr, :bakFile, :table_name, :rate_file_name, :tempS1, :tempS2, :resUsed_Bef, :resUsed_Aft, :tempS3
  #实际结果


  def initialize(testId)
    $LOG.info "initialize BillTestDriver ...".green
    @testId = eval "config.TestEnvParam.#{testId.to_s}.testId"
    @testName = eval "config.TestEnvParam.#{testId.to_s}.testName"
    @free_code1 = eval "config.TestEnvParam.#{testId.to_s}.free_code1"
    @redisStrs = eval "config.TestEnvParam.#{testId.to_s}.redisStrs"

    #主机参数
    @linuxIpAccount = eval "config.TestEnvParam.#{testId.to_s}.hostInfo.linuxIpAccount"
    @linuxIpAddr = eval "config.TestEnvParam.#{testId.to_s}.hostInfo.linuxIpAddr"
    @passWord = eval "config.TestEnvParam.#{testId.to_s}.hostInfo.passWord"
    @bDS_Adr = eval "config.TestEnvParam.#{testId.to_s}.hostInfo.bDS_Adr"
    @inputDirPath = eval "config.TestEnvParam.#{testId.to_s}.hostInfo.inputDirPath"

    #用户参数
    @user_id = eval "config.TestEnvParam.#{testId.to_s}.userInfo.user_id"
    @serial_number = eval "config.TestEnvParam.#{testId.to_s}.userInfo.serial_number"
    @acct_id = eval "config.TestEnvParam.#{testId.to_s}.userInfo.acct_id"
    @senderChannle = eval "config.TestEnvParam.#{testId.to_s}.userInfo.senderChannle"
    @sqlDbStr = eval "config.TestEnvParam.#{testId.to_s}.userInfo.sqlDbStr"
    @channel = eval "config.TestEnvParam.#{testId.to_s}.userInfo.channel"
    @feepolicyId = eval "config.TestEnvParam.#{testId.to_s}.userInfo.feepolicyId"
    @resCode = eval "config.TestEnvParam.#{testId.to_s}.userInfo.resCode"

    #话单文件
    @bakFile = eval "config.TestEnvParam.#{testId.to_s}.bakFile"
    @rate_file_name="RATE_6002_sz_dxzxsx"
    $LOG.info "原始话单：#{@bakFile.to_s}".green

    #初始化相关变量
    @dateMon=Time.now.strftime "%m"
    #系统时间（年月日）
    @strAcct_day=Time.now.strftime"%Y%m" +'01'
    #系统时间（年月）
    @strCycle_id=Time.now.strftime"%Y%m"
    #当前月的第一天完整日期表示
    @currentOneDay=Time.now.strftime"%Y%m" +'01'
    #当前日期
    @dateCurrent=Time.now.strftime"%Y%m%d%H%M%S"
    @today=Time.now.strftime"%Y%m%d"
    @thistime=Time.now.strftime"%H%M%S"


  end

  def selectACT_bill sqlstr
    session=OCI8.new(config.TestEnvParam.billACTDataBase.Account,config.TestEnvParam.billACTDataBase.Password,config.TestEnvParam.billACTDataBase.DataBase)
    #加载orcle数据库接口类
    #ucr_act1/ucr_act1@nbact
    query = sqlstr
    cursor = session.parse(query)
    cursor.exec()
    #获取查询结果数组
    result = cursor.fetch
    #拼接结果查询数据
    return result
  end

  def selectnb_bil sqlstr
    begin
      session=OCI8.new(config.TestEnvParam.nbbilDataBase.Account,config.TestEnvParam.nbbilDataBase.Password,config.TestEnvParam.nbbilDataBase.DataBase)
      #加载orcle数据库接口类
      #ucr_act1/ucr_act1@nbact
      query = sqlstr
      cursor = session.parse(query)
      cursor.exec()
      #获取查询结果数组
      result = cursor.fetch
      #拼接结果查询数据
      return result
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def creatNotebill
    @table_name="tg_cdr#{@dateMon}_sm"
    $LOG.info "原始话单#{@bakFile}".green
    @bakFile_arr=@bakFile.split(',')
    num1=@bakFile_arr[27]
    num2=@bakFile_arr[28]
    num3=@bakFile_arr[29]
    num4=@bakFile_arr[30]
    #sqlDbStr="ucr_td04/ucr_td04@nbbil"  未完成230-232
    ##sqlBossDb >returnSqlStr.temp
    ##a=`grep -n "\--" returnSqlStr.temp|awk -F ":" '{print $1}'`
    ##a=`expr $a + 1`
    #@dateString=`cat returnSqlStr.temp|sed -n "$a"p|sed 's/^[ \t]*//g'`
    returnSqlarr=selectACT_bill "SELECT to_char(sysdate, 'yyyymmdd')||','||to_char(sysdate, 'mmdd')||','|| to_char(sysdate -10/(24*60),'hh24miss')||','||to_char(sysdate -10/(24*60)+173/(24*60*60),'hh24miss')||','||to_char(sysdate -10/(24*60),'yyyymmddhh24miss')||','||to_char(last_day(sysdate),'yyyymmdd') FROM dual"
    @dateString=returnSqlarr.join ','
    @dateString_arr=@dateString.split(',')
    #yyyymmdd
    time1=@dateString_arr[0]
    #mmdd
    time2=@dateString_arr[1]
    #sysdate -10/(24*60),'hh24miss'
    time3=@dateString_arr[2]
    #sysdate -10/(24*60)+173/(24*60*60),'hh24miss'
    time4=@dateString_arr[3]
    #sysdate -10/(24*60),'yyyymmddhh24miss'
    @time5=@dateString_arr[4]
    #Last day
    @currentLastDay=@dateString_arr[5]
    @bakFile="1 #{@channel} 21,2,09151643251388857616501790418890,0,790418890,00,0,,460026067495459,#{@serial_number},0,18288914531,,901901,10658038,,,,0,1,136,0898,0898,,,13800871500,,#{@today},#{@thistime},#{@today},#{@thistime},#{@time5},1,000,,,,0,189,3,1,,0926105138,1,0T,1,1,01,1005,1,139,,0,#{@user_id},#{@acct_id},71006601,G003,898,898,,7,71006015,G003,0,20111218103610,0898,0898,,,,,,,,,,,,,,,,,,,#{@acct_id}"

    @bakFile=@bakFile.gsub(/num4/,@time5).gsub(/num1/,time1).gsub(/num2/,time3).gsub(/num3/,time4)
    $LOG.info "本次测试话单为：#{@bakFile.to_s}".green
    @bakFile
  end

  def creatGPRSbill strGPRS
    @table_name="tg_cdr#{@dateMon}_gs"
    $LOG.info "原始话单#{@bakFile}".green
    @bakFile_arr=@bakFile.split(',')
    num1=@bakFile_arr[27]
    num2=@bakFile_arr[28]
    num3=@bakFile_arr[29]
    num4=@bakFile_arr[30]
    #sqlDbStr="ucr_td04/ucr_td04@nbbil"  未完成230-232
    ##sqlBossDb >returnSqlStr.temp
    ##a=`grep -n "\--" returnSqlStr.temp|awk -F ":" '{print $1}'`
    ##a=`expr $a + 1`
    #@dateString=`cat returnSqlStr.temp|sed -n "$a"p|sed 's/^[ \t]*//g'`
    returnSqlarr=selectACT_bill "SELECT to_char(sysdate, 'yyyymmdd')||','||to_char(sysdate, 'mmdd')||','|| to_char(sysdate -10/(24*60),'hh24miss')||','||to_char(sysdate -10/(24*60)+173/(24*60*60),'hh24miss')||','||to_char(sysdate -10/(24*60),'yyyymmddhh24miss')||','||to_char(last_day(sysdate),'yyyymmdd') FROM dual"
    @dateString=returnSqlarr.join ','
    @dateString_arr=@dateString.split(',')
    #yyyymmdd
    time1=@dateString_arr[0]
    #mmdd
    time2=@dateString_arr[1]
    #sysdate -10/(24*60),'hh24miss'
    time3=@dateString_arr[2]
    #sysdate -10/(24*60)+173/(24*60*60),'hh24miss'
    time4=@dateString_arr[3]
    #sysdate -10/(24*60),'yyyymmddhh24miss'
    @time5=@dateString_arr[4]
    #Last day
    @currentLastDay=@dateString_arr[5]
    @bakFile="1 #{@channel} 33,3,100100090418889193786DDB17#{@time5},1,1,,#{@serial_number},460078894822866,DDB171C5,,30052,,0000014202,320339688,DF671708,CMNET,,,0ABFC5BB,0,1 ,N,0898,0898,,,0,,8658990297784078,#{@today},000904,32,A,#{strGPRS},0,32,B,0,0,0,C,0,0,0,D,0,0,0,E,0,0,0,F,0,0,0,0,0,0,0,,0GGH898A2110010009.8280,,56,0,0,1,DDB171C5,,320339688,,,,10092305,002,002,#{@user_id},#{@acct_id},10004062,01,G010,473,HNWN,,20120527120514,0,,,,,,,,,,,,,#{@acct_id}"
    @bakFile=@bakFile.gsub(/num4/,@time5).gsub(/num1/,time1).gsub(/num2/,time3).gsub(/num3/,time4)
    $LOG.info "本次测试话单为：#{@bakFile.to_s}".green
    @bakFile
  end

  def creatMISCbill
    @table_name="tg_cdr#{@dateMon}_misc"
    $LOG.info "原始话单#{@bakFile}".green
    @bakFile_arr=@bakFile.split(',')
    num1=@bakFile_arr[27]
    num2=@bakFile_arr[28]
    num3=@bakFile_arr[29]
    num4=@bakFile_arr[30]
    #sqlDbStr="ucr_td04/ucr_td04@nbbil"  未完成230-232
    ##sqlBossDb >returnSqlStr.temp
    ##a=`grep -n "\--" returnSqlStr.temp|awk -F ":" '{print $1}'`
    ##a=`expr $a + 1`
    #@dateString=`cat returnSqlStr.temp|sed -n "$a"p|sed 's/^[ \t]*//g'`
    returnSqlarr=selectACT_bill "SELECT to_char(sysdate, 'yyyymmdd')||','||to_char(sysdate, 'mmdd')||','|| to_char(sysdate -10/(24*60),'hh24miss')||','||to_char(sysdate -10/(24*60)+173/(24*60*60),'hh24miss')||','||to_char(sysdate -10/(24*60),'yyyymmddhh24miss')||','||to_char(last_day(sysdate),'yyyymmdd') FROM dual"
    @dateString=returnSqlarr.join ','
    @dateString_arr=@dateString.split(',')
    #yyyymmdd
    time1=@dateString_arr[0]
    #mmdd
    time2=@dateString_arr[1]
    #sysdate -10/(24*60),'hh24miss'
    time3=@dateString_arr[2]
    #sysdate -10/(24*60)+173/(24*60*60),'hh24miss'
    time4=@dateString_arr[3]
    #sysdate -10/(24*60),'yyyymmddhh24miss'
    @time5=@dateString_arr[4]
    #Last day
    @currentLastDay=@dateString_arr[5]
    @bakFile="1 #{@channel} 4n,4,10032150064n10032151#{@time5},1,1003215131700000111137,#{@serial_number},460022089087389,,00,02,0,01,0,#{@today},215006,#{@today},215007,1,,,,0,2,,701001,,400120002000,0,2000,0,0,C.20151003898.264,0,0,0,02,,99,,7000001,,0000,,100,00100,0000000200,41276000,,,,,,,,,,,,,1009231812,#{@user_id},#{@acct_id},10003800,01,G002,475,0898,HNWC,,0,,0898,0898,,,1,0,2000,0,0,,,0,20140208102541,20151001,,#{@acct_id}"
    @bakFile=@bakFile.gsub(/num4/,@time5).gsub(/num1/,time1).gsub(/num2/,time3).gsub(/num3/,time4)
    $LOG.info "本次测试话单为：#{@bakFile.to_s}".green
    @bakFile
  end

  def creatVoicebill
    @table_name="tg_cdr#{@dateMon}"
    $LOG.info "原始话单#{@bakFile}".green
    @bakFile_arr=@bakFile.split(',')
    num1=@bakFile_arr[27]
    num2=@bakFile_arr[28]
    num3=@bakFile_arr[29]
    num4=@bakFile_arr[30]
    #sqlDbStr="ucr_td04/ucr_td04@nbbil"  未完成230-232
    ##sqlBossDb >returnSqlStr.temp
    ##a=`grep -n "\--" returnSqlStr.temp|awk -F ":" '{print $1}'`
    ##a=`expr $a + 1`
    #@dateString=`cat returnSqlStr.temp|sed -n "$a"p|sed 's/^[ \t]*//g'`
    returnSqlarr=selectACT_bill "SELECT to_char(sysdate, 'yyyymmdd')||','||to_char(sysdate, 'mmdd')||','|| to_char(sysdate -10/(24*60),'hh24miss')||','||to_char(sysdate -10/(24*60)+173/(24*60*60),'hh24miss')||','||to_char(sysdate -10/(24*60),'yyyymmddhh24miss')||','||to_char(last_day(sysdate),'yyyymmdd') FROM dual"
    @dateString=returnSqlarr.join ','
    @dateString_arr=@dateString.split(',')
    #yyyymmdd
    time1=@dateString_arr[0]
    #mmdd
    time2=@dateString_arr[1]
    #sysdate -10/(24*60),'hh24miss'
    time3=@dateString_arr[2]
    #sysdate -10/(24*60)+173/(24*60*60),'hh24miss'
    time4=@dateString_arr[3]
    #sysdate -10/(24*60),'yyyymmddhh24miss'
    @time5=@dateString_arr[4]
    #Last day
    @currentLastDay=@dateString_arr[5]
    @bakFile="1 #{@channel} 11,1,999#{@time5},1,01,460008824855152,#{@serial_number},15812345678,#{@today},150652,#{@today},150945,173,,8613441888,34900,26393,,,,,000,21,,0898,0898,0898,0898,0,lj8201406161508.F1085,,18289334613,,,,863361026860380,0,,,,,0,0,1,0,0,000,,,,,,,,000,20150616,15812345678,1,,1,,1,,,00,,,0,30,0,20,,,19,,,,,,,#{@user_id},#{@acct_id},,01,,2,,,,,,,,,,,,,,,,,,,,,,#{@acct_id}"
    @bakFile=@bakFile.gsub(/num4/,@time5).gsub(/num1/,time1).gsub(/num2/,time3).gsub(/num3/,time4)
    $LOG.info "本次测试话单为：#{@bakFile.to_s}".green
    @bakFile
  end

  def getResponse uri
    begin
      require "open-uri"
      html_response = nil
      open(uri) do |http|
        html_response = http.read
      end
      html_response
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  #BDS查询账单数据
  def getBDSData
    begin
      server_cmd="#{@bDS_Adr}/bds/userbill/QAM_AllUserBillInfo?CONTENT={\"USER_EPARCHY_CODE\":\"0898\",\"ACCT_ID\":\"#{@acct_id}\",\"USER_ID\":\"#{@user_id}\",\"EPARCHY_CODE\":\"0898\",\"ACCT_DAY\":\"#{@strAcct_day}\",\"CYCLE_ID\":\"#{@strCycle_id}\",\"USER_IDS_TRANSIN\":\"#{@user_id}\",\"ASP\":\"1\"}"
      $LOG.info "BDS查询账单数据字符串：#{server_cmd.to_s}".green
      result=getResponse server_cmd
      $LOG.info "账单数据：#{result.to_s}".green
      result
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end
  # 通过BDS接口查询用户免费资源使用量
  def getBDSResData res_code
    begin
      server_cmd="#{@bDS_Adr}/bds/ResUsed/QAM_QryDiscntUseByUser?CONTENT={\"USER_EPARCHY_CODE\":\"0898\",\"USER_ID\":\"#{@user_id}\",\"ACCT_ID\":\"#{@acct_id}\",\"ASP\":\"1\",\"USER_BEGIN_DATE\":\"#{@currentOneDay}\",\"USER_END_DATE\":\"#{@currentLastDay}\",\"MONTH\":\"#{@strCycle_id}\",\"EPARCHY_CODE\":\"0898\"}"
      $LOG.info "BDS查询GPRS资源使用情况字符串：#{server_cmd.to_s}".green
      result=getResponse server_cmd
      $LOG.info "资源使用情况：#{result.to_s}".green
      result=JSON.parse result
      if result["RESULT_DATA"] !=nil
        result["RESULT_DATA"].each do |n|
          if n["RES_CODE"].to_s==res_code

            return n["VALUE"].to_s
          end
        end
      else

      end
      return 0
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end
  # 通过BDS接口查询升档套餐资源使用量
  def getBDSGradeData res_id
    begin
      server_cmd="#{@bDS_Adr}/bds/ResGrade/QAM_QryGradeDiscntUseByUser?CONTENT={\"ACCT_ID\":\"#{@acct_id}\",\"EPARCHY_CODE\":\"0898\",\"USER_BEGIN_DATE\":\"#{@currentOneDay}\",\"USER_END_DATE\":\"#{@currentLastDay}\",\"USER_ID\":\"#{@user_id}\",\"ASP\":\"1\"}"
      $LOG.info "BDS查询GPRS升档资源使用情况字符串：#{server_cmd.to_s}".green
      result=getResponse server_cmd
      $LOG.info "升档套餐资源使用情况：#{result.to_s}".green
      result=JSON.parse result
      if result["RESULT_DATA"] !=nil
        result["RESULT_DATA"].each do |n|
          if n["RES_ID"].to_s==res_id
            return n["GRADE"]
          end
        end
      else
        return 0
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def diffFreeCode_sms
    begin
      $LOG.info "优惠轨迹查询开始：select free_code from #{@table_name} where file_no='#{@time5}' and user_id='#{@user_id}'".green
      mySqlStr="select free_code from #{@table_name} where file_no='#{@time5}' and user_id='#{@user_id}'"
      @free_code2=selectnb_bil mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..1800
        @free_code2=selectnb_bil mySqlStr
        if @free_code2 !=nil  then
          break
        else
          sleep 1
          next
        end
      end
      if @free_code2 !=nil then
        @free_code2=@free_code2.join.split('|')[4]
        $LOG.info "查询到记录：#{@free_code2}".green
      else
        $LOG.info "未查询到记录".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def diffFreeCode_voice
    begin
      $LOG.info "优惠轨迹查询开始：select free_code from #{@table_name} where fid='999#{@time5}' and user_id='#{@user_id}'".green
      mySqlStr="select free_code from #{@table_name} where fid='999#{@time5}' and user_id='#{@user_id}'"
      @free_code2=selectnb_bil mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..1800
        @free_code2=selectnb_bil mySqlStr
        if @free_code2 !=nil  then
          break
        else
          sleep 1
          next
        end
      end
      if @free_code2 !=nil then
        @free_code2=@free_code2.join.split('|')[4]
        $LOG.info "查询到记录：#{@free_code2}".green
      else
        $LOG.info "未查询到记录".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def diffFreeCode_gprs
    begin
      $LOG.info "优惠轨迹查询开始：select free_code from #{@table_name} where fid='100100090418889193786DDB17#{@time5}' and user_id='#{@user_id}'".green
      mySqlStr="select free_code from #{@table_name} where fid='100100090418889193786DDB17#{@time5}' and user_id='#{@user_id}'"
      @free_code2=selectnb_bil mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..1800
        @free_code2=selectnb_bil mySqlStr
        if @free_code2 !=nil  then
          break
        else
          sleep 1
          next
        end
      end
      if @free_code2 !=nil then
        @free_code2=@free_code2.join.split('|')[4]
        $LOG.info "查询到记录：#{@free_code2}".green
      else
        $LOG.info "未查询到记录".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def diffFreeCode_misc
    begin
      $LOG.info "优惠轨迹查询开始：select free_code from #{@table_name} where fid='10032150064n10032151#{@time5}' and user_id='#{@user_id}'".green
      mySqlStr="select free_code from #{@table_name} where fid='10032150064n10032151#{@time5}' and user_id='#{@user_id}'"
      @free_code2=selectnb_bil mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..1800
        @free_code2=selectnb_bil mySqlStr
        if @free_code2 !=nil  then
          break
        else
          sleep 1
          next
        end
      end
      if @free_code2 !=nil then
        @free_code2=@free_code2.join.split('|')[4]
        $LOG.info "查询到记录：#{@free_code2}".green
      else
        $LOG.info "未查询到记录".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def getBillUser tempS1,tempS2,itemId
    begin
      $LOG.info "#{tempS1}"
      $LOG.info "#{tempS2}"

      tempS1_fee=0
      tempS1_discntFee=0
      tempS1_adjustFee=0
      tempS2_fee=0
      tempS2_discntFee=0
      tempS2_adjustFee=0
      tempS1=JSON.parse tempS1
      tempS2=JSON.parse tempS2
      iTEM_ID=itemId
      tempS1["RESULT_DATA"]["DEFAULT_USERBILL"].each do |n|
        if n["ITEM_ID"].to_s==itemId
          tempS1_fee=n["FEE"]
          tempS1_discntFee=n["DISCNT_FEE"]
          tempS1_adjustFee=n["ADJUST_FEE"]
        end
      end
      tempS2["RESULT_DATA"]["DEFAULT_USERBILL"].each do |n|
        if n["ITEM_ID"].to_s==itemId
          tempS2_fee=n["FEE"]
          tempS2_discntFee=n["DISCNT_FEE"]
          tempS2_adjustFee=n["ADJUST_FEE"]
        end
      end
      fee=tempS2_fee.to_i-tempS1_fee.to_i
      discntFee=tempS2_discntFee.to_i-tempS1_discntFee.to_i
      adjustFee=tempS2_adjustFee.to_i-tempS1_adjustFee.to_i
      @bILL_USER_TEST="#{iTEM_ID} #{fee} #{discntFee} #{adjustFee}"
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def fileTransferServer
    begin
      #将触发文件放入到入口目录
      send_cmd1="cd #{@inputDirPath}"
      send_cmd2="echo \"#{@bakFile}\" >#{@rate_file_name}_#{@dateCurrent}.txt"
      require 'net/ssh'
      # 连接到远程主机
      ssh = Net::SSH.start(@linuxIpAddr, @linuxIpAccount, :password => @passWord) do |ssh|
        $LOG.info "传送文件：#{send_cmd1};#{send_cmd2}".green
        result = ssh.exec!("#{send_cmd1};#{send_cmd2}")
        $LOG.info "#{result}".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def select_o_oht_msm
    begin
      $LOG.info "短信工单表查询开始：SELECT notice_content FROM TI_OHT_SMS t where t.recv_id='#{@user_id}' order by force_start_time desc".green
      mySqlStr="SELECT notice_content FROM TI_OHT_SMS t where t.recv_id='#{@user_id}' order by force_start_time desc"
      @sms_str=selectACT_bill mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..59
        @sms_str=nil
        @sms_str=selectACT_bill mySqlStr
        if @sms_str !=nil  then

          if @sms_str[0].encode(Encoding.find("utf-8"),Encoding.find("gbk")).to_s.sub(/[\d][\d]月[\d][\d]日[\d][\d]时[\d][\d]分/,"月日时分")==@sms_expectation.sub(/[\d][\d]月[\d][\d]日[\d][\d]时[\d][\d]分/,"月日时分")
            break
          else
            sleep 1
            next
          end
        else
          sleep 1
          next
        end
      end
      if @sms_str !=nil then
        @sms_str=@sms_str[0].encode(Encoding.find("utf-8"),Encoding.find("gbk"))
        $LOG.info "查询到记录#{@sms_str}".green
      else
        @sms_str=''
        $LOG.info "未查询到记录".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end

  def select_m_remind_work
    begin
      $LOG.info "短信工单表查询开始：SELECT states FROM tf_m_remind_work where remind_code =10001 and user_id='#{@user_id}'".green
      mySqlStr="SELECT states FROM tf_m_remind_work where remind_code =10001 and user_id='#{@user_id}'"
      @remind_state =selectACT_bill mySqlStr
      #300秒循环查询工单，提前完工则提前跳出
      for i in 0..59
        @remind_state=selectACT_bill mySqlStr
        if @remind_state !=nil  then
          if @remind_state[0].to_s=='3'
            break
          else
            sleep 1
            next
          end
        else
          sleep 1
          next
        end
      end
      if @remind_state !=nil then
        @remind_state=@remind_state[0].to_s
      else
        @remind_state=''
      end
      if @remind_state =='3' then
        $LOG.info "短信工单完工，状态为：#{@sms_str}".green
      else
        $LOG.info "短信工单未完工，状态为：#{@sms_str}".green
      end
    rescue => ex
      $LOG.error "#{ex}".red
      raise
    end
  end
end


