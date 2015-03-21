class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
  end

  def update
    return if Project.active.count == 0

    active_url = URIGrabber.grab
    project_for_entry = nil
    if active_url.start_with?(Project.active.first.urlString)
      project_for_entry = Project.active.first
    else
      project_for_entry = Project.find_none
    end

    if @active_entry && @active_entry.project != project_for_entry
      @active_entry.finish
      @active_entry = Entry.start_for_project(project_for_entry)
    elsif @active_entry.nil?
      @active_entry = Entry.start_for_project(project_for_entry)
    end
    @cdq.save
  end
end
