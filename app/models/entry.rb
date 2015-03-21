class Entry < CDQManagedObject
  def start
    self.startedAt = Time.now
  end

  def finish
    self.finishedAt = Time.now
    self.duration = self.finishedAt - self.startedAt
  end
end
