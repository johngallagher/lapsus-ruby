class ActiveDocumentTracker
  attr_accessor :activeDocument
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
  end

  def dealloc
    cancelTimer
    super
  end

  def watch
    observeActiveDocument
    updateActiveDocument

    addTimer
  end

  def addTimer
    @timer = EM.add_periodic_timer 1.0 do
      updateActiveDocument
    end
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

