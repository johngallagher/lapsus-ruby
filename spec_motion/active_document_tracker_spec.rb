require "spec_helper"

describe ActiveDocumentTracker do
  before do
    @shared_app = NSApplication.sharedApplication
    @app_delegate = @shared_app.delegate
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)
  end

  after do
    @app_delegate.cdq.reset!
  end

  it "records time for two projects" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts")
    careers = Project.create(name: "Careers", urlString: "file://Users/John/Careers")
    midnight = Time.new(2014, 6, 2, 0, 0, 0)

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: midnight)
    @tracker.update

    URIGrabber.stub!(:grab, return: "file://Users/John/Careers/main.rb")
    Time.stub!(:now, return: midnight + 2)
    @tracker.update

    URIGrabber.stub!(:grab, return: "missingfile://")
    Time.stub!(:now, return: midnight + 4)
    @tracker.update

    Entry.count.should == 3

    first_entry = Entry.first
    first_entry.project.should == autoparts
    first_entry.startedAt.should == midnight
    first_entry.finishedAt.should == midnight + 2
    first_entry.duration.should == 2

    second_entry = Entry.all.to_a[1]
    second_entry.project.should == careers
    second_entry.startedAt.should == midnight + 2
    second_entry.finishedAt.should == midnight + 4
    second_entry.duration.should == 2

    third_entry = Entry.all.to_a[2]
    third_entry.project.should == Project.find_none
    third_entry.startedAt.should == midnight + 4
    third_entry.finishedAt.should.nil?
    third_entry.duration.should == 0
  end

  it "records time for a project" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts", none: 0)
    autoparts_start_time = Time.new(2014, 6, 2, 0, 0, 0)

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: autoparts_start_time)

    @tracker.update

    URIGrabber.stub!(:grab, return: "missingfile://")
    Time.stub!(:now, return: autoparts_start_time + 2)

    @tracker.update

    Entry.count.should == 2

    first_entry = Entry.first
    first_entry.project.should == autoparts
    first_entry.startedAt.should == autoparts_start_time
    first_entry.finishedAt.should == autoparts_start_time + 2
    first_entry.duration.should == 2

    second_entry = Entry.all.to_a[1]
    second_entry.project.should == Project.find_none
    second_entry.startedAt.should == autoparts_start_time + 2
    second_entry.finishedAt.should.nil?
    second_entry.duration.should == 0
  end

  it "assigns off project time to no project" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts", none: 0)
    start_time = Time.new(2014, 6, 2, 0, 0, 0)

    URIGrabber.stub!(:grab, return: "missingfile://")
    Time.stub!(:now, return: start_time)

    @tracker.update

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: start_time + 2)

    @tracker.update

    Entry.count.should == 2

    first_entry = Entry.first
    first_entry.project.should == Project.find_none
    first_entry.duration.should == 2

    second_entry = Entry.all.to_a[1]
    second_entry.project.should == autoparts
  end

  it "with no active projects it doesn't track" do
    start_time = Time.new(2014, 6, 2, 0, 0, 0)

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: start_time)

    @tracker.update

    Entry.count.should == 0
  end
end
