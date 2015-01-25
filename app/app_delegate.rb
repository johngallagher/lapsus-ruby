class Entry < CDQManagedObject
  def duration
    if finishedAt && startedAt
      finishedAt - startedAt 
    else
      0
    end
  end
end
class MainWindowController < NSWindowController; end
class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item, :tracker, :timer, :moc

  def applicationDidFinishLaunching(notification)
    
    cdq.setup
    self.moc = cdq.contexts.current
    setupMenuBar
    setupMainWindow
    observeActiveDocumentChanges
    startTrackingDocuments
    true
  end

  def applicationWillTerminate(notification)
    @activeEntry.finishedAt = Time.now
    cdq.save
  end

  def observeActiveDocumentChanges
    @center = NSWorkspace.sharedWorkspace.notificationCenter
    @center.addObserver(self, 
                        selector: 'activeDocumentDidChange:', 
                        name: 'com.synapticmishap.documentDidChange', 
                        object: nil)
  end

  def activeDocumentDidChange(notification)
    document = notification.userInfo['JGActiveDocument']
    if document.nil? 
      @activeEntry.finishedAt = Time.now if @activeEntry
      puts "#{Time.now} - Stopped last recording on sleep or inactivity."
      @activeEntry = nil
    elsif !@activeEntry && document
      @activeEntry = createEntryWithDocument(document)
      puts "#{Time.now} - Started fresh recording on wake. #{@activeEntry.attributes}"
    elsif @activeEntry.url != document.url || @activeEntry.application_bundle_id != document.bundleIdentifier
      @activeEntry.finishedAt = Time.now
      puts "Stopped old recording entry #{@activeEntry.attributes}"
      @activeEntry = createEntryWithDocument(document)
      puts "Started new recording entry #{@activeEntry.attributes}"
    end
    cdq.save
  end

  def createEntryWithDocument(document)
    Entry.create(startedAt: Time.now, url: document.url.absoluteString, path: document.url.path, application_bundle_id: document.bundleIdentifier)
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
