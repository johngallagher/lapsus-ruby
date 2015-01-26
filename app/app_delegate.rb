class Container < CDQManagedObject
  def container?
    true
  end

  def destroy
    projects.each { |p| p.destroy }
    super
  end
end
class Project < CDQManagedObject
  def container?
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
class MainWindowController < NSWindowController
  include CDQ

  def windowDidLoad
    @outlineView = window.contentView.viewWithTag(1)
  end

  def outlineView(outlineView, child: childIndex, ofItem: item)
    if item.nil?
      Container.all[childIndex]
    elsif item.container?
      item.projects[childIndex]
    end
  end

  def outlineView(outlineView, isItemExpandable: item)
    item && item.container? && item.projects.count > 0
  end

  def outlineView(outlineView, numberOfChildrenOfItem: item)
    if item.nil?
      Container.count
    elsif item.container?
      item.projects.count
    end
  end

  def outlineView(outlineView, viewForTableColumn: tableColumn, item: item)
    tableCellView = outlineView.makeViewWithIdentifier('DataCell', owner: self)
    tableCellView.textField.stringValue = item.name
    tableCellView
  end

  def addContainer(object)
    openDlg = NSOpenPanel.openPanel
    openDlg.canChooseFiles = false
    openDlg.canChooseDirectories = true
    if openDlg.runModal == NSOKButton
      openDlg.URLs.each do |filename|
        manager = NSFileManager.defaultManager
        selectedFolderURL = openDlg.URLs.first
        urls = manager.contentsOfDirectoryAtURL(selectedFolderURL,
                                                includingPropertiesForKeys: [NSURLPathKey, NSURLIsDirectoryKey],
                                                options: 0,
                                                error: nil)
        directories = urls.select do |url|
          directoryPointer = Pointer.new(:object)
          url.getResourceValue(directoryPointer, forKey: NSURLIsDirectoryKey, error: nil)
          directoryPointer[0]
        end

        projects = directories.map do |directory|
          Project.create(name: directory.lastPathComponent, path: directory.absoluteString)
        end

        container = Container.create(name: selectedFolderURL.lastPathComponent, path: selectedFolderURL.absoluteString)
        projects.each do |project|
          container.projects << project
        end

        cdq.save
        @outlineView.reloadData
      end
    end
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
    #c = Container.first
    #c.projects << Project.first
    #cdq.save
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
