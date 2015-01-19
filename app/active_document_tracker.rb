class ActiveDocumentTracker
  attr_accessor :activeDocument
  include BW::KVO

  def initialize
    @grabber = DocumentGrabber.new
    @center = NSWorkspace.sharedWorkspace.notificationCenter
  end

  def dealloc
    EM.cancel_timer(@timer)
    super
  end

  def watch
    observeActiveDocument
    updateActiveDocument

    @timer = EM.add_periodic_timer 1.0 do
      updateActiveDocument
    end
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
      @center.postNotificationName('com.synapticmishap.documentDidChange',
                                   object: nil,
                                   userInfo: { 'JGActiveDocument' => newActiveDocument })
    end
  end
end

