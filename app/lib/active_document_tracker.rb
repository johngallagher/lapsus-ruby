class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
  end

  def update
    return if Project.active.count == 0

    current_project = find_current_project

    if @active_entry && @active_entry.project != current_project
      @active_entry.finish
      @active_entry = Entry.start_for_project(current_project)
    elsif @active_entry.nil?
      @active_entry = Entry.start_for_project(current_project)
    end
    @cdq.save
  end

  def find_current_project
    url = URIGrabber.grab
    if url.start_with?(Project.active.first.urlString)
      Project.active.first
    else
      Project.find_none
    end
  end
end
