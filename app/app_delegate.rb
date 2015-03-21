class FakeURIGrabber
  attr_accessor :uri

  def grab
    @uri
  end
end


class FakeIdleDetector
  attr_accessor :idle

  def initialize
    @idle = false
  end

  def idle?
    @idle
  end
end

class FakeDate
  attr_accessor :now
end

class AppDelegate
  include CDQ
  attr_reader :idle_detector, :uri_grabber, :time_class, :tracker

  def applicationDidFinishLaunching(_notification)
    if RUBYMOTION_ENV == 'test'
      cdq.stores.new(in_memory: true)
      @idle_detector = FakeIdleDetector.new
      @uri_grabber = FakeURIGrabber.new
      @time_class = FakeDate.new
    else
      @idle_detector = IdleDetector.new
      @uri_grabber = URIGrabber.new
      @time_class = Time
    end 

    cdq.setup

    @tracker = ActiveDocumentTracker.new(cdq, @uri_grabber, @idle_detector, @time_class)

    if RUBYMOTION_ENV == 'test'
      @timer = nil
    else
      @timer = EM.add_periodic_timer 1.0 do
        @tracker.update
      end
    end
    true
  end
end
