
class ActiveDocumentTracker
  IDLE_TIME = 30

  def initialize(cdq, idle_detector = IdleDetector.new)
    @cdq = cdq
    @none = Activity.find_or_create_none
    @idle = Activity.find_or_create_idle
    @active_activities = Activity.active
    @active_entry = Entry.start(@none)
    @idle_detector = idle_detector
    @started_idling_at = nil
  end

  def update
    return if @active_activities.count == 0

    activity = find_activity

    return if @active_entry.activity == activity

    changed_activity_at = Time.now
    changed_activity_at = Time.now - IDLE_TIME if activity == @idle

    @active_entry.finish(changed_activity_at)
    @active_entry = Entry.start(activity, changed_activity_at)
    @cdq.save
  end

  def find_activity
    @started_idling_at = Time.now if @idle_detector.idle? && !@started_idling_at

    if @idle_detector.idle? && @started_idling_at + IDLE_TIME <= Time.now
      @started_idling_at = nil
      return @idle
    else
      url = URIGrabber.grab
      @active_activities.find(->{ @none }){ |activity| url.start_with?(activity.urlString) }
    end
  end
end
