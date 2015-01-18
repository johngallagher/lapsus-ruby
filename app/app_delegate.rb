class Entry < CDQManagedObject; end
class MainWindowController < NSWindowController; end
class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item, :tracker, :timer

  def applicationDidFinishLaunching(notification)
    cdq.setup
    setupMenuBar
    setupMainWindow
    observeActiveDocumentChanges
    startTrackingDocuments
    true
  end

  def observeActiveDocumentChanges
    @center = NSWorkspace.sharedWorkspace.notificationCenter
    @center.addObserver(self, 
                        selector: 'activeDocumentDidChange:', 
                        name: 'com.synapticmishap.documentDidChange', 
                        object: nil)
  end

  def activeDocumentDidChange(notification)
    newActiveDocument = notification.userInfo['JGActiveDocument']
    puts "Changed active application to #{newActiveDocument.bundleIdentifier}"
    puts "Changed active document to #{newActiveDocument.url.absoluteString}"
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
    @status_menu.addItem createMenuItem("Quit", 'terminate:')
  end

  def setupMainWindow
    @controller = MainWindowController.alloc.initWithWindowNibName('MainWindow')
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def showLapsusWindow
    @controller.window.makeKeyAndOrderFront(self)
  end
end
