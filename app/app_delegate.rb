class ActiveDocumentGrabber
  def initialize(bundle_identifier)
    puts "About to compile for #{bundle_identifier}"
    source = %Q[
      tell application "System Events"
        value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundle_identifier}"))
      end tell
    ]
    puts "1"
    @script = NSAppleScript.alloc.initWithSource(source)
    puts "2"
    error_ptr = Pointer.new(:object)
    puts "3"
    success = @script.compileAndReturnError(error_ptr)
    puts "4"
    if !success
      puts "Error on compile!"
      #error = error_ptr[0]
      #puts "Error on compilation: #{error}"
      @script = nil
    end
    puts "4.5"
  end

  def grab
    puts "5"
    return nil if @script.nil?

    error_ptr = Pointer.new(:object)
    activeUrl = @script.executeAndReturnError(error_ptr)
    if !activeUrl
      puts "Error on execute!"
      nil
    else
      NSURL.URLWithString(activeUrl.stringValue)
    end
  end
end

class Entry < CDQManagedObject; end
class MainWindowController < NSWindowController; end

class Tracker
  attr_reader :activeEntry
  def initialize(cdq, bundle_identifier)
    @cdq = cdq

    @bundle_identifier = bundle_identifier
    @grabber = ActiveDocumentGrabber.new(bundle_identifier)


     #Create default entry
    #activeUrl = @grabber.grab
    #if activeUrl
      #@activeEntry = Entry.create(startedAt: Time.now,
                                  #url: activeUrl.absoluteString,
                                  #scheme: activeUrl.scheme,
                                  #host: activeUrl.host,
                                  #path: activeUrl.path,
                                  #application_bundle_id: @active_bundle_identifier,
                                  #application_name: @active_application_name)
    #else
      #@activeEntry = Entry.create(startedAt: Time.now,
                                  #url: '',
                                  #scheme: '',
                                  #host: '',
                                  #path: '',
                                  #application_bundle_id: @active_bundle_identifier,
                                  #application_name: @active_application_name)
    #end
    #@cdq.save
  end

  def updateActiveEntry
    activeUrl = @grabber.grab
    entryHasChanged = activeUrl && (activeUrl != @activeEntry.url || @bundle_identifier != @activeEntry.bundle_identifier)

    if entryHasChanged
      @activeEntry.finishedAt = Time.now
      @activeEntry = Entry.create(startedAt: Time.now,
                                  url: activeUrl.absoluteString,
                                  scheme: activeUrl.scheme,
                                  host: activeUrl.host,
                                  path: activeUrl.path,
                                  application_bundle_id: @bundle_identifier,
                                  application_name: nil)
      @cdq.save
      puts "It just updated!"
    elsif !activeUrl && !@activeEntry
      @activeEntry = Entry.create(startedAt: Time.now,
                                  url: '',
                                  scheme: '',
                                  host: '',
                                  path: '',
                                  application_bundle_id: @bundle_identifier,
                                  application_name: nil)
      @cdq.save

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
    setupTracker(cdq)
    true
  end

  def applicationWillTerminate(notification)
    EM.cancel_timer(@timer)
    true
  end

  def setupTracker(context)
    active_bundle_identifier = NSRunningApplication.currentApplication.bundleIdentifier
    #@active_application_name = NSRunningApplication.currentApplication.localizedName
    @tracker = Tracker.new(cdq, active_bundle_identifier)
    @tracker.updateActiveEntry

    @center = NSWorkspace.sharedWorkspace.notificationCenter
    @center.addObserver(self, selector: 'appDidChange:', name: NSWorkspaceDidActivateApplicationNotification, object: nil)

    @timer = EM.add_periodic_timer 1.0 do
      @tracker.updateActiveEntry
      puts "Active entry is now: #{@tracker.activeEntry.attributes}"
    end
  end

  def appDidChange(notification)
    @tracker = nil
    application = notification.userInfo.valueForKey NSWorkspaceApplicationKey
    active_bundle_identifier= application.bundleIdentifier
    @tracker = Tracker.new(cdq, active_bundle_identifier)
    @tracker.updateActiveEntry
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
