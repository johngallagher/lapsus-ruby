class Entry < CDQManagedObject
  
end
class MainWindowController < NSWindowController
end

class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item

  def applicationDidFinishLaunching(notification)
    cdq.setup

    setupMenuBar
    setupMainWindow
    true
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
    @status_menu.addItem createMenuItem("Create Entry", 'createEntry')
    @status_menu.addItem createMenuItem("Quit", 'terminate:')
  end

  def setupMainWindow
    @controller = MainWindowController.alloc.initWithWindowNibName('MainWindow')
  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  # Actions
  def showLapsusWindow
    @controller.window.makeKeyAndOrderFront(self)
  end

  def createEntry
    Entry.create(startedAt: Time.now - 100, finishedAt: Time.now, scheme: 'file', host: 'localhost', path: '/Users/John/Lapsus/main.rb')
    cdq.save
  end
end
