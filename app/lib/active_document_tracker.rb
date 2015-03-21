class ActiveDocumentTracker
  def initialize(cdq)
    @cdq = cdq
  end

  def update
    return if Project.count == 0

    active_url = URIGrabber.grab
    puts "Active url is #{active_url}"
    if active_url.start_with?(Project.first.urlString)
      @active_entry = Entry.create
      @active_entry.start
      @active_entry.project = Project.first
      puts "1"
    elsif @active_entry
      @active_entry.finish
      @cdq.save
      puts "2"
    else
      puts "Nothing"
    end
  end
end
