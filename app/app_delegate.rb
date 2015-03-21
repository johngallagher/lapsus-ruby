class AppDelegate
  include CDQ
  attr_reader :idle_detector, :uri_grabber, :time_class, :tracker

  def applicationDidFinishLaunching(_notification)
    if RUBYMOTION_ENV == 'test'
      cdq.stores.new(in_memory: true)
    end 

    cdq.setup

    @tracker = ActiveDocumentTracker.new(cdq)

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
