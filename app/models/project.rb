class Project < CDQManagedObject
  def self.create_none
    none_project = Project.find_none
    if none_project
      none_project
    else
      Project.create(name: "None", none: 1)
    end
  end

  def self.create_idle
    idle = Project.find_idle
    if idle
      return idle
    else
      Project.create(name: "Idle")
    end
  end

  def self.find_idle
    Project.where(:name).eq("Idle").first
  end

  def self.active
    Project.where(:none).eq(0)
  end

  def self.find_none
    Project.where(:none).eq(1).first
  end

  def none?
    if none == 1
      true
    else
      false
    end
  end
end
