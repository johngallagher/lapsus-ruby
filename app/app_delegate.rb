class PreferencesController < NSWindowController; end
class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item, :tracker, :timer, :moc

  def applicationDidFinishLaunching(notification)
    cdq.setup
    self.moc = cdq.contexts.current
    setupMenuBar
    setupMainWindow
    setupPreferencesWindow
    startTrackingDocuments
    showLapsusWindow
    true
  end

  def applicationWillTerminate(notification)
    if self.activeEntry
      self.activeEntry.finish
    end
    cdq.save
  end

  def startTrackingDocuments
    @activeDocumentTracker = ActiveDocumentTracker.new
    @activeDocumentTracker.watch
  end

  def setupMenuBar
    @app_name = NSBundle.mainBundle.infoDictionary['CFBundleDisplayName']

    @status_menu = NSMenu.new

    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    @status_item.setTitle('1')
    @status_item.setImage(NSImage.imageNamed("clock.png"))
    @status_item.setAlternateImage(NSImage.imageNamed("clock.png"))

    @status_menu.addItem createMenuItem("See Reports...", 'showLapsusWindow')
    @status_menu.addItem createMenuItem("Preferences...", 'showPreferences')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')
  end

  def setupMainWindow
    @controller = MainWindowController.alloc.initWithWindowNibName('MainWindow')
  end

  def setupPreferencesWindow
    @preferencesController = PreferencesController.alloc.initWithWindowNibName('Preferences')
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def showLapsusWindow
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
    @controller.window.makeKeyAndOrderFront(self)
  end

  def showPreferences
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
    @preferencesController.window.makeKeyAndOrderFront(self)
  end
end
