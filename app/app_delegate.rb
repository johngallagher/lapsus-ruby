class AppDelegate
  include CDQ

  def applicationDidFinishLaunching(_notification)
    cdq.setup

    @tracker = ActiveDocumentTracker.new(cdq)

    if RUBYMOTION_ENV != "test"
      @timer = EM.add_periodic_timer 1.0 do
        @tracker.update
      end
    end
    true
  end
end
