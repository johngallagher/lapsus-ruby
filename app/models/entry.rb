class Entry < CDQManagedObject
  def self.start_for_project(project)
    entry = Entry.create
    entry.startedAt = Time.now
    entry.project = project
    entry
  end

  def finish
    self.finishedAt = Time.now
    self.duration = finishedAt - startedAt
  end
end
