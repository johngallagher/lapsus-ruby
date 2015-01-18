class Entry < CDQManagedObject; end
class MainWindowController < NSWindowController; end
class DocumentGrabber
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
    Document.new(url: NSURL.URLWithString(grabActiveDocumentUrl), bundleIdentifier: @bundleIdentifier)
  end

  private
  def grabActiveDocumentUrl
    activeUrl = @script.executeAndReturnError(nil)
    (activeUrl && activeUrl.stringValue) ? activeUrl.stringValue : 'missingfile://'
  end
end

class Document
  attr_accessor :url, :bundleIdentifier

  def initialize(attrs)
    @bundleIdentifier = attrs.fetch(:bundleIdentifier)
    @url = attrs.fetch(:url)
  end
end

class ActiveDocumentTracker
  attr_accessor :activeDocument
  include BW::KVO

  def initialize
    @center = NSWorkspace.sharedWorkspace.notificationCenter
    @center.addObserver(self, 
                        selector: 'applicationDidChangeFromNotification:', 
                        name: NSWorkspaceDidActivateApplicationNotification, 
                        object: nil)
  end

  def dealloc
    EM.cancel_timer(@timer)
    @center.removeObserver(self,
                           name: NSWorkspaceDidActivateApplicationNotification,
                           object: nil)
  end

  def applicationDidChangeFromNotification(notification)
    application = notification.userInfo.valueForKey NSWorkspaceApplicationKey
    applicationDidChange(application)
  end

  def watch
    observeActiveDocument
    applicationDidChange(NSWorkspace.sharedWorkspace.frontmostApplication)
    @timer = EM.add_periodic_timer 1.0 do
      document = @grabber.activeDocument
      documentHasChanged = self.activeDocument.url != document.url
      documentDidChange(document) if documentHasChanged
    end
  end

  private
  def observeActiveDocument
    observe(self, :activeDocument) do |oldActiveDocument, newActiveDocument|
      @center.postNotificationName('com.synapticmishap.documentDidChange',
                                   object: nil,
                                   userInfo: { 'JGActiveDocument' => newActiveDocument })
    end
  end

  def applicationDidChange(application)
    @grabber = DocumentGrabber.new(application.bundleIdentifier)
    documentDidChange(@grabber.activeDocument)
  end

  def documentDidChange(document)
    self.activeDocument = document
  end
end

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
