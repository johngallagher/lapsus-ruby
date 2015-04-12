class ActiveDocumentTracker
  def initialize(cdq, workspace = NSWorkspace.sharedWorkspace)
    @cdq = cdq
    @grabber = URIGrabber.new(workspace)

    Activity.find_or_create_idle
    none = Activity.find_or_create_none
    @entry = Entry.start(none)
    @cdq.save
  end

  def update
    current_activity = Activity.from_uri(@grabber.grab)

    return if current_activity == @entry.activity || current_activity.last_active?

    @entry.finish
    @entry.remove_idle_time_from_finish if current_activity.idle?

    @entry = Entry.start(current_activity)
    @cdq.save
  end

  def stop
    current_activity = Activity.from_uri(@grabber.grab)
    @entry.finish
    @entry.remove_idle_time_from_finish if current_activity.idle?
    @cdq.save
  end
end
