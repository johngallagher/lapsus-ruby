class AppDelegate
  include CDQ

  def applicationDidFinishLaunching(_notification)
    return true if RUBYMOTION_ENV == "test"

    cdq.setup
    @tracker = ActiveDocumentTracker.new(cdq)
    @timer = EM.add_periodic_timer 1.0 do
      @tracker.update
    end
    true
  end

  def applicationWillTerminate(_notification)
    @tracker.stop
  end
end
