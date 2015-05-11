class AppDelegate
  include CDQ


  def applicationDidFinishLaunching(_)
    return true if RUBYMOTION_ENV == "test"

    cdq.setup

    @tracker = ActiveDocumentTracker.new(cdq)
    @timer = EM.add_periodic_timer 1.0 do
      @tracker.update
    end

    @main_window_controller = MainWindowController.alloc.initWithWindowNibName('MainWindow')
    @main_window_controller.window.makeKeyAndOrderFront(self)
    expandRootInSourceList

    true
  end

  def expandRootInSourceList
    source_list = @main_window_controller.source_list_controller.outline_view
    source_list.expandItem(source_list.itemAtRow(0))
  end

  def applicationWillBecomeActive(_)
    @tracker.update
    @main_window_controller.source_list_controller.reload
    @main_window_controller.project_summary_controller.date_selector.dateValue = NSDate.date
  end

  def applicationWillTerminate(_)
    @tracker.stop
  end
end
