class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
    @no_project = Project.create_none
    @active_projects = Project.active.sort_by(:name)
  end

  def update
    return if @active_projects.count == 0

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
    if url.start_with?(@active_projects.first.urlString)
      @active_projects.first
    else
      @no_project
    end
  end
end
