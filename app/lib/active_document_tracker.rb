class ActiveDocumentTracker
  def initialize(cdq, grabber, idle_detector)
    @grabber, @idle_detector = grabber, idle_detector
    @cdq = cdq
  end

  def update
    return if Project.count == 0

    active_url = @grabber.grab
    if active_url.start_with?(Project.first.urlString)
      @active_entry = Entry.create
      @active_entry.start
      @active_entry.project = Project.first
    elsif @active_entry
      @active_entry.finish
      @cdq.save
    end
  end
end
