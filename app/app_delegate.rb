class Project < CDQManagedObject
  def root
    false
  end
end
class Entry < CDQManagedObject
  def duration
    if finishedAt && startedAt
      finishedAt - startedAt 
    else
      0
    end
  end
end
class RootNode
  def name
    'PROJECTS'
  end

  def root
    true
  end
end

class Node
  def name
    'hello'
  end
  def root
    false
  end
end
class MainWindowController < NSWindowController
  def outlineView(outlineView, child: child, ofItem: item)
    if child == 0
      RootNode.new
    else
      Node.new
    end
  end

  def outlineView(outlineView, isItemExpandable: item)
    false
  end

  def outlineView(outlineView, numberOfChildrenOfItem: item)
    5
  end

  def outlineView(outlineView, viewForTableColumn: tableColumn, item: item)
    if item.root
      tableCellView = outlineView.makeViewWithIdentifier('HeaderCell', owner: self)
      tableCellView.textField.textColor = NSColor.headerColor
      tableCellView.textField.font = NSFont.boldSystemFontOfSize(NSFont.smallSystemFontSize)
    else
      tableCellView = outlineView.makeViewWithIdentifier('DataCell', owner: self)
    end
    tableCellView.textField.stringValue = item.name
    tableCellView
  end
end
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
    observeActiveDocumentChanges
    startTrackingDocuments
    showLapsusWindow
    true
  end

  def applicationWillTerminate(notification)
    if @activeEntry
      @activeEntry.finishedAt = Time.now
      cdq.save
    end
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
    url = (document.url ? document.url.absoluteString : '')
    path = (document.url ? document.url.path : '')
    Entry.create(startedAt: Time.now, url: url, path: path, application_bundle_id: document.bundleIdentifier)
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
