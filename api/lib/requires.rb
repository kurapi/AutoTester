# filename: api/lib/requires.rb

# require config helper
require_relative 'helpers/api_config_helper.rb'

# require the ios page checker
require_relative 'pages/inner_screen.rb'

# require control helper
require_relative 'pages/control.rb'

# require environment initializer
require_relative 'helpers/api_env_helper'

# setup driver
require_relative 'helpers/api_driver_helper'

# require output colorization
require_relative 'helpers/api_colorize'

# require testcase helper
require_relative 'helpers/api_testcase_helper'

# require test testcases converter helper
require_relative 'helpers/api_converter_helper'

# require logger helper
require_relative 'helpers/api_logger_helper'

# require ios simulator helper
require_relative 'helpers/api_simulator_helper'

require_relative 'helpers/api_html_reporter'

require_relative 'helpers/api_ngbossSQL_helper'