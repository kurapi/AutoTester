# encoding: UTF-8
# filename: bill/lib/requires.rb

# require config helper
require Dir.pwd+'/bill/lib/pages/actions'

require Dir.pwd+'/bill/lib/helpers/bill_config_helper.rb'

# require the ios page checker
require Dir.pwd+'/bill/lib/pages/inner_screen.rb'

# require control helper
require Dir.pwd+'/bill/lib/pages/control.rb'

# require environment initializer
require Dir.pwd+'/bill/lib/helpers/bill_env_helper'

# setup driver
require Dir.pwd+'/bill/lib/helpers/bill_driver_helper'

# require output colorization
require Dir.pwd+'/bill/lib/helpers/bill_colorize'

# require testcase helper
require Dir.pwd+'/bill/lib/helpers/bill_testcase_helper'

# require test testcases converter helper
require Dir.pwd+'/bill/lib/helpers/bill_converter_helper'

# require logger helper
require Dir.pwd+'/bill/lib/helpers/bill_logger_helper'

# require ios simulator helper
require Dir.pwd+'/bill/lib/helpers/bill_simulator_helper'

require Dir.pwd+'/bill/lib/helpers/bill_html_reporter'

require Dir.pwd+'/bill/lib/helpers/bill_ngbossSQL_helper'