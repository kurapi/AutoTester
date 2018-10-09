# filename: android/lib/requires.rb

# require config helper
require_relative 'helpers/android_config_helper.rb'

# require the android page checker
require_relative 'pages/inner_screen'

# require control helper
require_relative 'pages/control'

# require environment initializer
require_relative 'helpers/android_env_helper'

# setup driver
require_relative 'helpers/android_driver_helper'

# require output colorization
require_relative 'helpers/android_colorize'

# require testcase helper
require_relative 'helpers/android_testcase_helper'

# require test testcases converter helper
require_relative 'helpers/android_converter_helper'

# require logger helper
require_relative 'helpers/android_logger_helper'

# require android simulator helper
require_relative 'helpers/android_simulator_helper'

# require testcase runner
require_relative 'runner_android'
