class ActiveDocumentTracker
  def initialize(cdq, workspace = NSWorkspace.sharedWorkspace)
    @cdq = cdq
    @idle = Activity.find_or_create_idle
    @none = Activity.find_or_create_none
    @entry = Entry.start(@none)
    current_application = NSRunningApplication.currentApplication
    @grabber = URIGrabber.new(workspace, current_application)
  end

  def update
    activity = Activity.current_from_active_uri(@grabber.grab)

    return if @entry.activity == activity || activity.previous?

    @entry.finish(activity)
    @entry = Entry.start(activity)
    @cdq.save
  end
end
