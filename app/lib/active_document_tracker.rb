class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
    @none = Activity.find_or_create_none
    @idle = Activity.find_or_create_idle
    @projects = Activity.projects
    @entry = Entry.start(@none)
    @user = User.new
  end

  def update
    activity = Activity.current(@user)

    return if @entry.activity == activity

    @entry.finish(activity)
    @entry = Entry.start(activity)
    @cdq.save
  end
end

class User
  IDLE_THRESHOLD = 30

  def initialize
    @started_idling_at = nil
  end

  def idle?
    @started_idling_at = Time.now if IdleDetector.idle? && !@started_idling_at

    if IdleDetector.idle? && @started_idling_at + IDLE_THRESHOLD <= Time.now
      @started_idling_at = nil
      true
    else
      false
    end
  end
end
