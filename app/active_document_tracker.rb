class ActiveDocumentTracker
  attr_accessor :activeDocument, :idleTime
  include BW::KVO

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
      updateActiveDocument
    end
  end

  def watch
    observeActiveDocument
    updateActiveDocument

    addTimer
  end

  def addTimer
    @timer = EM.add_periodic_timer 1.0 do
      if userIdle?
        puts "user is idle"
        self.activeDocument = nil if self.activeDocument
      else
        updateActiveDocument
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
  def updateActiveDocument
    bundleIdentifier = NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
    document = @grabber.activeDocument(bundleIdentifier)

    documentHasChanged = self.activeDocument.nil? || self.activeDocument.url != document.url || self.activeDocument.bundleIdentifier != bundleIdentifier
    self.activeDocument = document if documentHasChanged
  end

  def observeActiveDocument
    observe(self, :activeDocument) do |oldActiveDocument, newActiveDocument|
      puts "Did post notification #{newActiveDocument}"
      @center.postNotificationName('com.synapticmishap.documentDidChange',
                                   object: nil,
                                   userInfo: { 'JGActiveDocument' => newActiveDocument })
    end
  end

  def machineWillSleep(notification)
    puts "Machine did sleep at #{Time.now}"
    cancelTimer
    self.activeDocument = nil
  end

  def machineDidWake(notification)
    puts "Machine did wake at #{Time.now}"
    updateActiveDocument
    addTimer
  end
end

