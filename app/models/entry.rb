class Entry < CDQManagedObject
  def self.start(activity)
    entry = Entry.create
    entry.startedAt = Entry.now_adjusted_for_idle_time(activity)
    entry.activity = activity
    entry
  end

  def finish(next_activity)
    self.finishedAt = Entry.now_adjusted_for_idle_time(next_activity)
    self.duration = finishedAt - startedAt
  end

  def self.now_adjusted_for_idle_time(activity)
    if activity.idle?
      Time.now - User::IDLE_TIME
    else
      Time.now
    end
  end

  def to_s
    attributes.merge(activity: activity.attributes)
  end

  def self.by_time
    Entry.sort_by(:startedAt)
  end
end
