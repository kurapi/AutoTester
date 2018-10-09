# encoding: UTF-8
#使用示例
#yaml数据查询
# readYaml("a")   读取TestData.yaml文件的a序列并返回
def readYaml yamlFile,yamlKey,yamlData
  yamlModule = YAML.load(File.open(Dir.pwd+"/web/steps/"+yamlFile))
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
def writeConfig yamlStr,yamlValue
  config_hash = YAML.load(File.open("#{Dir.pwd}\\web\\"+'config.yml'))
  yamlArr=yamlStr.split('.')
  yamlEvalStr="config_hash"
  for i in 1..yamlArr.length-1
    yamlEvalStr+=('[\''+(yamlArr[i].to_s)+'\']')
  end
  yamlEvalStr+="=#{yamlValue.to_s}"
  eval yamlEvalStr
  File.open("#{Dir.pwd}\\web\\"+'config.yml',"wb"){|f| YAML.dump(config_hash, f)}
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

