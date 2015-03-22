class Activity < CDQManagedObject
  def self.find_or_create_none
    none_project = Activity.find_none
    if none_project
      none_project
    else
      Activity.create(name: "None", type: "none")
    end
  end

  def self.find_or_create_idle
    idle = Activity.find_idle
    if idle
      return idle
    else
      Activity.create(name: "Idle", type: "idle")
    end
  end

  def self.active
    Activity.where(:type).eq("project").sort_by(:name)
  end

  def self.find_idle
    Activity.where(:type).eq("idle").first
  end

  def self.find_none
    Activity.where(:type).eq("none").first
  end
end
