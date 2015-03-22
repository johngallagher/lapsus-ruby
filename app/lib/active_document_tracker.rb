class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
    @idle = Activity.find_or_create_idle
    @none = Activity.find_or_create_none
    @entry = Entry.start(@none)
  end

  def update
    activity = Activity.current

    return if @entry.activity == activity

    @entry.finish(activity)
    @entry = Entry.start(activity)
    @cdq.save
  end
end
