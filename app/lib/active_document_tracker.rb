class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
    @no_project = Project.create_none
    @active_projects = Project.active.sort_by(:name)
    @active_entry = Entry.start_for_project(@no_project)
  end

  def update
    return if @active_projects.count == 0

    active_project = find_active_project
    return if @active_entry.project == active_project

    @active_entry.finish
    @active_entry = Entry.start_for_project(active_project)
    @cdq.save
  end

  def find_active_project
    url = URIGrabber.grab
    @active_projects.find(->{ @no_project }){ |project| url.start_with?(project.urlString) }
  end
end
