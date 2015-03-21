require "spec_helper"

describe ActiveDocumentTracker do
  before do
    @shared_app = NSApplication.sharedApplication
    @app_delegate = @shared_app.delegate

    @midnight = Time.new(2014, 6, 2, 0, 0, 0)
    simulate(time: @midnight)
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)
  end

  after do
    @app_delegate.cdq.reset!
  end

  it "records time for two projects" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts")
    careers = Project.create(name: "Careers", urlString: "file://Users/John/Careers")

    simulate(time: @midnight + 2, uri: "file://Users/John/Autoparts/main.rb")
    @tracker.update

    simulate(time: @midnight + 4, uri: "file://Users/John/Careers/main.rb")
    @tracker.update

    simulate(time: @midnight + 6, uri: "missingfile://")
    @tracker.update

    Entry.count.should == 4

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.project.should == Project.find_none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + 4, "duration" => 2 }
    second_entry.project.should == autoparts

    third_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => @midnight + 6, "duration" => 2 }
    third_entry.project.should == careers

    fourth_entry.attributes.should == { "startedAt" => @midnight + 6, "finishedAt" => nil, "duration" => 0 }
    fourth_entry.project.should == Project.find_none
  end

  it "records time for a project" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts", none: 0)

    simulate(time: @midnight + 2, uri: "file://Users/John/Autoparts/main.rb")
    @tracker.update

    simulate(time: @midnight + 4, uri: "missingfile://")
    @tracker.update

    Entry.count.should == 3

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.project.should == Project.find_none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + 4, "duration" => 2 }
    second_entry.project.should == autoparts

    third_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => nil, "duration" => 0 }
    third_entry.project.should == Project.find_none
  end

  it "assigns off project time to no project" do
    autoparts = Project.create(name: "Autoparts", urlString: "file://Users/John/Autoparts", none: 0)

    simulate(time: @midnight + 2, uri: "missingfile://")
    @tracker.update

    simulate(time: @midnight + 4, uri: "file://Users/John/Autoparts/main.rb")
    @tracker.update

    Entry.count.should == 2

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 4, "duration" => 4 }
    first_entry.project.should == Project.find_none

    second_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => nil, "duration" => 0 }
    second_entry.project.should == autoparts
  end

  it "with no active projects it doesn't track" do
    @tracker.update

    Entry.count.should == 1
  end
end

def first_entry
  Entry.by_time.to_a[0]
end

def second_entry
  Entry.by_time.to_a[1]
end

def third_entry
  Entry.by_time.to_a[2]
end

def fourth_entry
  Entry.by_time.to_a[3]
end

def simulate(attrs)
  URIGrabber.stub!(:grab, return: attrs[:uri]) if attrs[:uri]
  Time.stub!(:now, return: attrs.fetch(:time))
end
