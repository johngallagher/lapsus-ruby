class Entry < CDQManagedObject; end
class MainWindowController < NSWindowController; end
class Application
  attr_accessor :bundleIdentifier

  def initialize(bundleIdentifier)
    @bundleIdentifier = bundleIdentifier
    source = %Q[
      tell application "System Events"
        value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundleIdentifier}"))
      end tell
    ]
    @script = NSAppleScript.alloc.initWithSource(source)
    @script.compileAndReturnError(nil)
  end

  def activeDocument
    activeUrl = @script.executeAndReturnError(nil)
    if activeUrl && activeUrl.stringValue
      Document.new(NSURL.URLWithString(activeUrl.stringValue)) 
    else
      MissingDocument.new
    end
  end
end

class Document
  attr_accessor :url

  def initialize(url)
    @url = url
  end

end


class MissingDocument
  def url
    NSURL.URLWithString('')
  end
end

class ActiveDocumentTracker
  def activeBundleIdentifier
    NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
  end

  def updateApplication
    @activeApplication = Application.new(activeBundleIdentifier)
    puts "Active Application did change to #{@activeApplication.bundleIdentifier}"
  end

  def updateDocument
    @activeDocument = @activeApplication.activeDocument
    puts "Active doc is #{@activeDocument.className}"
    puts "Active Document did change to #{@activeDocument.url.absoluteString}"
  end

  def poll
    applicationHasChanged = @activeApplication.bundleIdentifier != activeBundleIdentifier
    if applicationHasChanged
      updateApplication
      updateDocument
      return
    end

    activeDocument = @activeApplication.activeDocument
    documentHasChanged = @activeDocument.url != activeDocument.url
    if documentHasChanged
      updateDocument 
    end
  end

  def watch
    updateApplication
    updateDocument
    EM.add_periodic_timer 1.0 do
      poll
    end
  end
end

class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item, :tracker, :timer

  def applicationDidFinishLaunching(notification)
    cdq.setup
    setupMenuBar
    setupMainWindow
    @activeDocumentTracker = ActiveDocumentTracker.new
    @activeDocumentTracker.watch
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
