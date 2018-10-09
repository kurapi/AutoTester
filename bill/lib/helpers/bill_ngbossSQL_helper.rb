# encoding: UTF-8
def selectCRM sqlstr
  #加载orcle数据库接口类
  #创建数据库连接实例 数据库信息走yaml配置
  session=OCI8.new(config.TestEnvParam.CRMDataBase.Account,config.TestEnvParam.CRMDataBase.Password,config.TestEnvParam.CRMDataBase.DataBase)
  query = sqlstr
  cursor = session.parse(query)
  puts query
  cursor.exec()
  #获取查询结果数组
  result = cursor.fetch
  #拼接结果查询数据
  return result
end

#使用示例
#中心库查询
# sqlstr为传入sql语句，返回值为查询到的第一条
def selectCEN sqlstr
  session=OCI8.new(config.TestEnvParam.CENDataBase.Account,config.TestEnvParam.CENDataBase.Password,config.TestEnvParam.CENDataBase.DataBase)
  query = sqlstr
  cursor = session.parse(query)
  cursor.exec()
  #获取查询结果数组
  result = cursor.fetch
  return result
end

#使用示例
#账务库查询
# sqlstr为传入sql语句，返回值为查询到的第一条
def selectACT sqlstr
  session=OCI8.new(config.TestEnvParam.ACTDataBase.Account,config.TestEnvParam.ACTDataBase.Password,config.TestEnvParam.ACTDataBase.DataBase)
  query = sqlstr
  cursor = session.parse(query)
  cursor.exec()
  #获取查询结果数组
  result = cursor.fetch
  return result
end



def check_order
  orderNumber = /\d{16}/
  @orderID= orderNumber.match(@orderStr).to_s
  #60秒循环查询工单，提前完工则提前跳出
  for i in 0..99
    query = 'select t.subscribe_state from ucr_crm1.tf_bh_trade t where order_id =\''+@orderID+'\''
    result = selectCRM(query)
    @result=result.join if result!=nil
    if @result =='9' then
      break
    else
      sleep 1
      next
    end
  end
  @orderID
end

def select_acctId_from_orderID orderID
  query = 'select ACCT_ID from ucr_crm1.tf_bh_trade where order_id=\''+orderID+'\''
  result = selectCRM(query)
  str1 = /\d{1,19}/
  result= str1.match(result.join).to_s
  result
end

def select_userId_from_orderID orderID
  query = 'select User_id from ucr_crm1.tf_bh_trade where order_id=\''+orderID+'\''
  result = selectCRM(query)
  str1 = /\d{1,19}/
  result= str1.match(result.join).to_s
  result
end

def select_SerialNumber_from_orderID orderID
  query = 'select serial_number from ucr_crm1.tf_bh_trade where order_id=\''+orderID+'\''
  result = selectCRM(query)
  str1 = /\d{1,12}/
  result= str1.match(result.join).to_s
  result
end

def WarningSms smsContent
  session=OCI8.new(config.TestEnvParam.CRMDataBase.Account,config.TestEnvParam.CRMDataBase.Password,config.TestEnvParam.CRMDataBase.DataBase)
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
  session=OCI8.new(config.TestEnvParam.CRMDataBase.Account,config.TestEnvParam.CRMDataBase.Password,config.TestEnvParam.CRMDataBase.DataBase)
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE,SERIAL_NUMBER,OPER_TYPE,TRADE_ID) values (sysdate,:serial_number,'+'\'UpdateCancelTag\''+',:trade_id)'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number,trade_id)
  session.commit()
end

#使用示例
#将传入的trade_id的用户的其它所有已返销工单置为未返销
def RecoverCancelTag serial_number,trade_id
  session=OCI8.new(config.TestEnvParam.CRMDataBase.Account,config.TestEnvParam.CRMDataBase.Password,config.TestEnvParam.CRMDataBase.DataBase)
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE,SERIAL_NUMBER,OPER_TYPE,TRADE_ID) values (sysdate,:serial_number,'+'\'RecoverCancelTag\''+',:trade_id)'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number,trade_id)
  session.commit()
end

#使用示例
#将传入号码置为非实名制
def RealName serial_number
  session=OCI8.new(config.TestEnvParam.CRMDataBase.Account,config.TestEnvParam.CRMDataBase.Password,config.TestEnvParam.CRMDataBase.DataBase)
  query = 'insert into TF_F_AUTOTEST_LOG (ACCEPT_DATE, SERIAL_NUMBER, OPER_TYPE) values (sysdate,:serial_number,'+'\'RealName\''+')'
  puts query
  cursor = session.parse(query)
  cursor.exec(serial_number)
  session.commit()
end