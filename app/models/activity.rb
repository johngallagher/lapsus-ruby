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

  def self.current(user)
    return Activity.find_idle if user.idle?
    return Activity.find_none if Activity.projects.array.empty?

    active_uri = URIGrabber.grab
    Activity.projects.find(->{ Activity.find_none }){ |project| active_uri.start_with?(project.urlString) }
  end

  def self.projects
    Activity.where(:type).eq("project").sort_by(:name)
  end

  def self.find_idle
    Activity.where(:type).eq("idle").first
  end

  def self.find_none
    Activity.where(:type).eq("none").first
  end

  def idle?
    type == "idle"
  end
end
