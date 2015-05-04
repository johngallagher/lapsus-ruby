class HelloController < NSViewController
  extend IB

  attr_accessor :data_source


  ## ib outlets
  outlet :scroller, NSScrollView
  outlet :btn_hello


  def say_hello(sender)
    # TODO Implement action here
  end


end