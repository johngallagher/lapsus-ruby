class ActiveDocumentTracker
  include CDQ
  attr_accessor :activeDocument, :idleTime, :activeEntry

  def initialize
    @grabber = DocumentGrabber.new
    @center = NSWorkspace.sharedWorkspace.notificationCenter
    @center.addObserver(self, 
                        selector: 'machineWillSleep:', 
                        name: NSWorkspaceWillSleepNotification, 
                        object: nil)
    @center.addObserver(self, 
                        selector: 'machineDidWake:', 
                        name: NSWorkspaceDidWakeNotification,
                        object: nil)
    self.idleTime = NSUserDefaults.standardUserDefaults['idleTime']
    @notificationCenter = NSNotificationCenter.defaultCenter
    @notificationCenter.addObserver(self,
                                    selector: 'defaultsChanged:',
                                    name: NSUserDefaultsDidChangeNotification,
                                    object: nil)
  end

  def dealloc
    cancelTimer
    super
  end

  def defaultsChanged(notification)
    self.idleTime = notification.object['idleTime']
    if userIdle?
      puts "user is idle"
      self.activeDocument = nil if self.activeDocument
    else
      updateActiveEntry
    end
  end

  def watch
    updateActiveEntry

    addTimer
  end

  def addTimer
    @timer = EM.add_periodic_timer 1.0 do
      if userIdle?
        puts "user is idle"
        self.activeEntry = nil
      else
        updateActiveEntry
      end
    end
  end

  def userIdle?
    timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(KCGEventSourceStateHIDSystemState, KCGAnyInputEventType)
    timeSinceLastEvent > self.idleTime.to_f * 60
  end

  def cancelTimer
    EM.cancel_timer(@timer)
  end

  private
  def updateActiveEntry
    bundleIdentifier = NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
    document = @grabber.activeDocument(bundleIdentifier)

    if inactive?(document)
      puts "Inactive document."
      self.activeEntry.finish
      self.activeEntry = nil
    elsif recoveringFromSleep?(document)
      puts "Recovering from sleepy time."
      self.activeEntry = Entry.create_and_start
      self.activeEntry.project = projectFor(document)
    elsif document.url.scheme == 'file' && self.activeEntry.project != projectFor(document)
      puts "Document #{document} has changed"
      self.activeEntry.finish
      self.activeEntry = Entry.create_and_start
      self.activeEntry.project = projectFor(document)
    end

    cdq.save
  end

  def recoveringFromSleep?(document)
    self.activeEntry.nil? && document
  end

  def inactive?(document)
    document.nil? 
  end

  def projectFor(document)
    return nil if document.nil?

    projectForDocument = nil
    Project.all.each do |project|
      project_path_components = project.urlPathComponents
      common_path_components = document.urlPathComponents[0..(project_path_components.length - 1)]
      documentIsWithinProject = (common_path_components == project_path_components)
      puts "Document is within project? #{documentIsWithinProject}"
      puts "Document url common path components are #{common_path_components}"
      puts "Project path components are #{project_path_components}"
      puts "Document path components are #{document.url.pathComponents}"
      if documentIsWithinProject
        projectForDocument = project
        break
      end
    end

    projectForDocument
  end

  def machineWillSleep(notification)
    puts "Machine did sleep at #{Time.now}"
    cancelTimer
    self.activeDocument = nil
  end

  def machineDidWake(notification)
    puts "Machine did wake at #{Time.now}"
    updateActiveEntry
    addTimer
  end
end

