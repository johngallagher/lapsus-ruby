require "spec_helper"

describe "application" do
  before do
    @shared_app = NSApplication.sharedApplication
    @app_delegate = @shared_app.delegate
    @app = LapsusApp.new(@app_delegate.cdq)
  end

  after do
    @app_delegate.cdq.reset!
  end

  it "records time for a project" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts", none: 0)
    autoparts_start_time = Time.new(2014, 6, 2, 0, 0, 0)

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: autoparts_start_time)

    @app.update_active_document

    URIGrabber.stub!(:grab, return: "missingfile://")
    Time.stub!(:now, return: autoparts_start_time + 2)

    @app.update_active_document

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

    @app.update_active_document

    URIGrabber.stub!(:grab, return: "file://Users/John/Autoparts/main.rb")
    Time.stub!(:now, return: start_time + 2)

    @app.update_active_document

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

    @app.update_active_document

    Entry.count.should == 0
  end
end
