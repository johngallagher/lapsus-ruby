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

