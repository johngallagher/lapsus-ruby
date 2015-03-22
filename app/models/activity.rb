class Activity < CDQManagedObject
  IDLE_NAME = 'Idle'
  IDLE_TYPE = 'idle'
  NONE_NAME = 'None'
  NONE_TYPE = 'none'
  PROJECT_TYPE = 'project'

  def self.find_or_create_none
    return none if none

    create(name: NONE_NAME, type: NONE_TYPE)
  end

  def self.find_or_create_idle
    return idle if idle

    create(name: IDLE_NAME, type: IDLE_TYPE)
  end

  def self.current(user)
    return idle if user.idle?
    return none if projects.array.empty?

    active_uri = URIGrabber.grab
    project_for(active_uri)
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
end
