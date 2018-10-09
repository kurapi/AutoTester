# encoding: UTF-8
# filename: web/lib/requires.rb

# require config helper
require Dir.pwd+'/web/lib/pages/actions'

require Dir.pwd+'/web/lib/helpers/web_config_helper.rb'

# require the ios page checker
require Dir.pwd+'/web/lib/pages/inner_screen.rb'

# require control helper
require Dir.pwd+'/web/lib/pages/control.rb'

# require environment initializer
require Dir.pwd+'/web/lib/helpers/web_env_helper'

# setup driver
require Dir.pwd+'/web/lib/helpers/web_driver_helper'

# require output colorization
require Dir.pwd+'/web/lib/helpers/web_colorize'

# require testcase helper
require Dir.pwd+'/web/lib/helpers/web_testcase_helper'

# require test testcases converter helper
require Dir.pwd+'/web/lib/helpers/web_converter_helper'

# require logger helper
require Dir.pwd+'/web/lib/helpers/web_logger_helper'

# require ios simulator helper
require Dir.pwd+'/web/lib/helpers/web_simulator_helper'

require Dir.pwd+'/web/lib/helpers/web_html_reporter'

require Dir.pwd+'/web/lib/helpers/web_ngbossSQL_helper'