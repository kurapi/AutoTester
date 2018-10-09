# filename: ios/lib/requires.rb

# require config helper
require_relative 'helpers/ios_config_helper.rb'

# require the ios page checker
require_relative 'pages/inner_screen'

# require control helper
require_relative 'pages/control'

# require environment initializer
require_relative 'helpers/ios_env_helper'

# setup driver
require_relative 'helpers/ios_driver_helper'

# require output colorization
require_relative 'helpers/ios_colorize'

# require testcase helper
require_relative 'helpers/ios_testcase_helper'

# require test testcases converter helper
require_relative 'helpers/ios_converter_helper'

# require logger helper
require_relative 'helpers/ios_logger_helper'

# require ios simulator helper
require_relative 'helpers/ios_simulator_helper'

# require testcase runner
require_relative 'runner_ios'
