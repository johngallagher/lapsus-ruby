class Activity < CDQManagedObject
  IDLE = "Idle"
  NONE = "None"
  PROJECT = "Project"
  PREVIOUS = "Previous"

  def self.find_or_create_none
    return none if none

    create(name: NONE, type: NONE)
  end

  def self.find_or_create_idle
    return idle if idle

    create(name: IDLE, type: IDLE)
  end

  def self.from_uri(uri)
    return idle if IdleDetector.idle?
    return none if projects.array.empty? || uri.start_with?(URIGrabber::MISSING_FILE_URL)
    return previous unless uri.start_with?("file://")

    project_for(uri)
  end

  def self.previous
    Activity.new(name: PREVIOUS, type: PREVIOUS)
  end

  def self.project_for(uri)
    projects.find(->{ none }){ |project| uri.start_with?(project.urlString) }
  end

  def self.projects
    where(:type).eq(PROJECT).sort_by(:name)
  end

  def self.idle
    where(:type).eq(IDLE).first
  end

  def self.none
    where(:type).eq(NONE).first
  end

  def idle?
    type == IDLE
  end

  def previous?
    type == PREVIOUS
  end
end
