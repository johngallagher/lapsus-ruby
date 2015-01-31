class Entry < CDQManagedObject
  def self.create_and_start
    Entry.create(startedAt: Time.now)
  end

  def finish
    self.finishedAt = Time.now
    self.duration = self.finishedAt - self.startedAt 
  end

  def projectName
    return '' if project.nil?

    self.project.name
  end
end

