class Project < CDQManagedObject
  def self.find_or_create_none
    none_project = Project.find_none
    if none_project
      none_project
    else
      Project.create(name: "None", type: "none")
    end
  end

  def self.find_or_create_idle
    idle = Project.find_idle
    if idle
      return idle
    else
      Project.create(name: "Idle", type: "idle")
    end
  end

  def self.active
    Project.where(:type).eq("project").sort_by(:name)
  end

  def self.find_idle
    Project.where(:type).eq("idle").first
  end

  def self.find_none
    Project.where(:type).eq("none").first
  end
end
