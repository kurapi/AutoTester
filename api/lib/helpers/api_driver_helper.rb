class ApiDriver

  def initialize(options)
    require 'soap/wsdlDriver'
    @soap_client =SOAP::WSDLDriverFactory.new(options).create_rpc_driver
  end

  def get_request_message requestMessage
    @request_message=requestMessage
  end

  def gusb_request_message(str_gusb_key,str_gusb_value)
    eval ("@request_message.gsub!(/#{str_gusb_key}=\\[.*?\\]/, \"#{str_gusb_key}=[\\\"#{str_gusb_value}\\\"]\")")
  end

  def start_driver
    @soap_client.businessCall(:requestMessage=>@request_message)
  end

end

#使用示例
#yaml数据查询
# readYaml("a")   读取TestData.yaml文件的a序列并返回
def readYaml yamlFile,yamlKey,yamlData
  require 'yaml'
  yamlModule = YAML.load(File.open(Dir.pwd+"/api/steps/"+yamlFile))
  yamlKeyArr=yamlKey.split('|')
  yamlModuleStr='yamlModule'
  yamlKeyArr.each do |n|
    yamlModuleStr+="[\""+n+"\"]"
  end
  puts yamlModuleStr
  return eval yamlModuleStr+"[\"#{yamlData}\"]"
end

#使用示例
#yaml数据重写
# writeYaml("a","b")   往TestData.yaml文件的a序列写入b属性
def writeYaml yamlData,yamlStr
  require 'yaml'
  yamlModule = YAML.load(File.open("features/step_definitons/config/TestData.yaml"))
  yamlModule["CRMBOSS"][yamlData]=yamlStr
  open('features/step_definitons/config/TestData.yaml', 'w') { |f| YAML.dump(yamlModule, f) }
end

#使用示例
#营业库查询
# sqlstr为传入sql语句，返回值为查询到的第一条


#使用示例
#短信发送
# smsContent为短信内容，短信不光发给配置的号码，局方也会收到一条
def WarningSms smsContent
  require 'OCI8'
  session=OCI8.new(readYaml('CRMDatabaseAcctount'),readYaml('CRMDatabasePassword'),readYaml('CRMDatabase'))
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE, SERIAL_NUMBER, OPER_TYPE,SMS_CONTENT) values (sysdate,18889745933,'+'\'WarningSms\''+',:smsContent)'
  puts query
  cursor = session.parse(query)
  cursor.exec(smsContent)
  session.commit()
end

#使用示例
#将传入的trade_id的用户的其它所有未返销工单置为已返销
#例：销户复机后，将复机trade_id传入，该号码的其它所有的未返销trade都置为已返销
def UpdateCancelTag serial_number,trade_id
  require 'OCI8'
  session=OCI8.new(readYaml('CRMDatabaseAcctount'),readYaml('CRMDatabasePassword'),readYaml('CRMDatabase'))
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE,SERIAL_NUMBER,OPER_TYPE,TRADE_ID) values (sysdate,:serial_number,'+'\'UpdateCancelTag\''+',:trade_id)'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number,trade_id)
  session.commit()
end

#使用示例
#将传入的trade_id的用户的其它所有已返销工单置为未返销
def RecoverCancelTag serial_number,trade_id
  require 'OCI8'
  session=OCI8.new(readYaml('CRMDatabaseAcctount'),readYaml('CRMDatabasePassword'),readYaml('CRMDatabase'))
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE,SERIAL_NUMBER,OPER_TYPE,TRADE_ID) values (sysdate,:serial_number,'+'\'RecoverCancelTag\''+',:trade_id)'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number,trade_id)
  session.commit()
end

#使用示例
#将传入号码置为非实名制
def RealName serial_number
  require 'OCI8'
  session=OCI8.new(readYaml('CRMDatabaseAcctount'),readYaml('CRMDatabasePassword'),readYaml('CRMDatabase'))
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE, SERIAL_NUMBER, OPER_TYPE) values (sysdate,:serial_number,'+'\'RealName\''+')'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number)
  session.commit()
end

#使用示例
#获取对于文本的服务号码
def getSerialNumber serialNumberStr
  require 'config/CRMBOSS.rb'
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
  require 'win32ole'
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

