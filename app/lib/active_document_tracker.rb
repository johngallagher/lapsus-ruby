
class ActiveDocumentTracker
  IDLE_TIME = 30

  def initialize(cdq, idle_detector = IdleDetector.new)
    @cdq = cdq
    @none = Activity.find_or_create_none
    @idle = Activity.find_or_create_idle
    @projects = Activity.projects
    @entry = Entry.start(@none)
    @idle_detector = idle_detector
    @started_idling_at = nil
  end

  def update
    return if @projects.count == 0

    activity = find_activity

    return if @entry.activity == activity

    changed_activity_at = Time.now
    changed_activity_at = Time.now - IDLE_TIME if activity == @idle

    @entry.finish(changed_activity_at)
    @entry = Entry.start(activity, changed_activity_at)
    @cdq.save
  end

  def find_activity
    @started_idling_at = Time.now if @idle_detector.idle? && !@started_idling_at

    if @idle_detector.idle? && @started_idling_at + IDLE_TIME <= Time.now
      @started_idling_at = nil
      return @idle
    else
      url = URIGrabber.grab
      @projects.find(->{ @none }){ |project| url.start_with?(project.urlString) }
    end
  end
end
