def selectCRM sqlstr
  #加载orcle数据库接口类
  require 'OCI8'
  #创建数据库连接实例 数据库信息走yaml配置
  session=OCI8.new(readYaml('CRMDatabaseAcctount'),readYaml('CRMDatabasePassword'),readYaml('CRMDatabase'))
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
  require 'OCI8'
  session=OCI8.new(readYaml('CENDatabaseAcctount'),readYaml('CENDatabasePassword'),readYaml('CENDatabase'))
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
  require 'OCI8'
  session=OCI8.new(readYaml('ACTDatabaseAcctount'),readYaml('ACTDatabasePassword'),readYaml('ACTDatabase'))
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
  i = 0
  for i in 0..99
    query = 'select t.subscribe_state from ucr_crm1.tf_bh_trade t where order_id =\''+@orderID+'\''
    @result = selectCRM(query).join
    if @result =='9' then
      break
    else
      sleep 1
      next
    end
  end
end