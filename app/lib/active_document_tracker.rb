class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
    @idle = Activity.find_or_create_idle
    @none = Activity.find_or_create_none
    @entry = Entry.start(@none)
  end

  def update
    uri = URIGrabber.grab
    activity = Activity.current_from_active_uri(uri)

    return if @entry.activity == activity || activity.previous?

    @entry.finish(activity)
    @entry = Entry.start(activity)
    @cdq.save
  end
end
