class AppDelegate
  include CDQ

  attr_reader :main_context

  def applicationDidFinishLaunching(_notification)
    return true if RUBYMOTION_ENV == "test"

    cdq.setup
    @main_context = cdq.contexts.current

    @tracker = ActiveDocumentTracker.new(cdq)
    @timer = EM.add_periodic_timer 1.0 do
      @tracker.update
    end

    @main_window_controller = MainWindowController.alloc.initWithWindowNibName('MainWindow')
    @main_window_controller.window.makeKeyAndOrderFront(self)

    true
  end

  def applicationWillTerminate(_notification)
    @tracker.stop
  end
end
