class Activity < CDQManagedObject
  IDLE_NAME = "Idle"
  IDLE_TYPE = "idle"
  NONE_NAME = "None"
  NONE_TYPE = "none"
  PROJECT_TYPE = "project"

  def self.find_or_create_none
    return none if none

    create(name: NONE_NAME, type: NONE_TYPE)
  end

  def self.find_or_create_idle
    return idle if idle

    create(name: IDLE_NAME, type: IDLE_TYPE)
  end

  def self.current_from_active_uri(uri)
    return idle if IdleDetector.idle?
    return none if projects.array.empty? || uri.start_with?(URIGrabber::MISSING_FILE_URL)
    return previous if !uri.start_with?("file://")

    project_for(uri)
  end

  def self.previous
    Activity.new(name: 'Previous', type: 'previous')
  end

  def self.project_for(uri)
    projects.find(->{ none }){ |project| uri.start_with?(project.urlString) }
  end

  def self.projects
    where(:type).eq(PROJECT_TYPE).sort_by(:name)
  end

  def self.idle
    where(:type).eq(IDLE_TYPE).first
  end

  def self.none
    where(:type).eq(NONE_TYPE).first
  end

  def idle?
    type == IDLE_TYPE
  end

  def previous?
    type == 'previous'
  end
end
