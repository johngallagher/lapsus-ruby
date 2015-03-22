
class ActiveDocumentTracker
  IDLE_TIME = 30

  def initialize(cdq, idle_detector = IdleDetector.new)
    @cdq = cdq
    @no_project = Project.find_or_create_none
    @idle_project = Project.find_or_create_idle
    @active_projects = Project.active
    @active_entry = Entry.start(@no_project)
    @idle_detector = idle_detector
    @started_idling_at = nil
  end

  def update
    return if @active_projects.count == 0

    active_project = find_active_project

    return if @active_entry.project == active_project

    changed_project_at = Time.now
    changed_project_at = Time.now - IDLE_TIME if active_project == @idle_project

    @active_entry.finish(changed_project_at)
    @active_entry = Entry.start(active_project, changed_project_at)
    @cdq.save
  end

  def find_active_project
    @started_idling_at = Time.now if @idle_detector.idle? && !@started_idling_at

    if @idle_detector.idle? && @started_idling_at + IDLE_TIME <= Time.now
      @started_idling_at = nil
      return @idle_project
    else
      url = URIGrabber.grab
      @active_projects.find(->{ @no_project }){ |project| url.start_with?(project.urlString) }
    end
  end
end
