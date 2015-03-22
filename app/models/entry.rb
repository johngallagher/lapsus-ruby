class Entry < CDQManagedObject
  def self.start(activity, start_at = Time.now)
    entry = Entry.create
    entry.startedAt = start_at
    entry.activity = activity
    entry
  end

  def finish(finish_at = Time.now)
    self.finishedAt = finish_at
    self.duration = finishedAt - startedAt
  end

  def to_s
    attributes.merge(activity: activity.attributes)
  end

  def self.by_time
    Entry.sort_by(:startedAt)
  end
end
