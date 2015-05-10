class Activity < CDQManagedObject
  IDLE = "Idle"
  NONE = "None"
  PROJECT = "Project"
  LAST_ACTIVE = "Last Active"

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
    return none if projects.array.empty? || uri.scheme == 'missingfile'
    return last_active if uri.scheme != 'file'

    project_for(uri)
  end

  def self.last_active
    Activity.new(name: LAST_ACTIVE, type: LAST_ACTIVE)
  end

  def self.project_for(uri)
    projects.find(->{ none }){ |project| uri.path.start_with?(project.url.path) }
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

  def url
    NSURL.URLWithString(urlString)
  end

  def idle?
    type == IDLE
  end

  def last_active?
    type == LAST_ACTIVE
  end

  def time_for(date_range)
    entries.where(:startedAt).ge(date_range.begin).and(:finishedAt).le(date_range.end).map(&:duration).reduce(0, :+)
  end
end
