# filename: lib/pages/inner_screen.rb

module Pages
  module InnerScreen
    class << self

    end # end of self
  end # end of InnerScreen
end # end of Pages

module Kernel
  def inner_screen
    Pages::InnerScreen
  end
  def screenshort
    time = Time.now.strftime "%Y-%m-%d_%H%M%S"
    screenshort_dir=@results_dir+"/screenshots/"+time+".jpg"
    Win32::Screenshot::Take.of(:foreground).write(screenshort_dir)
    screenshort_dir
  end
end
