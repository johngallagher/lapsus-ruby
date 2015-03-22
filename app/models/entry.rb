class Entry < CDQManagedObject
  def self.start(project, start_at = Time.now)
    entry = Entry.create
    entry.startedAt = start_at
    entry.project = project
    entry
  end

  def finish(finish_at = Time.now)
    self.finishedAt = finish_at
    self.duration = finishedAt - startedAt
  end

  def to_s
    attributes.merge(project: project.attributes)
  end

  def self.by_time
    Entry.sort_by(:startedAt)
  end
end
