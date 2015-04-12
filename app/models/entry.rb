class Entry < CDQManagedObject
  def self.start(activity)
    entry = Entry.create
    entry.startedAt = Time.now
    entry.activity = activity
    entry.add_idle_time_to_start if activity.idle?
    entry
  end

  def finish
    self.finishedAt = Time.now
    update_duration
  end

  def add_idle_time_to_start
    self.startedAt -= IdleDetector::IDLE_THRESHOLD
  end

  def remove_idle_time_from_finish
    self.finishedAt -= IdleDetector::IDLE_THRESHOLD
    update_duration
  end

  def update_duration
    self.duration = finishedAt - startedAt
  end

  def to_s
    attributes.merge(activity: activity.attributes)
  end

  def self.by_time
    Entry.sort_by(:startedAt)
  end
end
