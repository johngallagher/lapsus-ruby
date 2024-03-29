require "spec_helper"

describe ActiveDocumentTracker do
  before do
    @shared_app = NSApplication.sharedApplication
    @app_delegate = @shared_app.delegate
    @app_delegate.cdq.setup
    @app_delegate.cdq.reset!

    @midnight = Time.new(2014, 6, 2, 0, 0, 0)
    user_is_active
  end

  after do
    @app_delegate.cdq.reset!
  end

  it "records time for two activities" do
    assume_autoparts_activity
    assume_careers_activity

    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    wait_until(@midnight + 2)
    active_uri_is("file://localhost/Users/John/Autoparts/main.rb")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("file://localhost/Users/John/Careers/main.rb")
    @tracker.update

    wait_until(@midnight + 6)
    active_uri_is(nil)
    @tracker.update

    Entry.count.should == 4

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + 4, "duration" => 2 }
    second_entry.activity.should == @autoparts

    third_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => @midnight + 6, "duration" => 2 }
    third_entry.activity.should == @careers

    fourth_entry.attributes.should == { "startedAt" => @midnight + 6, "finishedAt" => nil, "duration" => 0 }
    fourth_entry.activity.should == none
  end

  it "records time for a activity" do
    assume_autoparts_activity

    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    wait_until(@midnight + 2)
    active_uri_is("file://localhost/Users/John/Autoparts/main.rb")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is(nil)
    @tracker.update

    Entry.count.should == 3

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + 4, "duration" => 2 }
    second_entry.activity.should == @autoparts

    third_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => nil, "duration" => 0 }
    third_entry.activity.should == none
  end

  it "assigns off activity time to no activity" do
    assume_autoparts_activity

    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    wait_until(@midnight + 2)
    active_uri_is(nil)
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("file://localhost/Users/John/Autoparts/main.rb")
    @tracker.update

    Entry.count.should == 2

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 4, "duration" => 4 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => nil, "duration" => 0 }
    second_entry.activity.should == @autoparts
  end

  it "with no projects it only tracks none" do
    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker
    @tracker.update

    Entry.count.should == 1
    first_entry.activity.should == none
  end

  it "stops recording when the user is idle and takes away the idle time and continues when they wake up" do
    assume_autoparts_activity

    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    user_is_idle
    wait_until(@midnight + idle_threshold + 2)
    @tracker.update

    user_is_active
    wait_until(@midnight + idle_threshold + 4)
    @tracker.update

    Entry.count.should == 3

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + idle_threshold + 4, "duration" => idle_threshold + 2 }
    second_entry.activity.should == idle

    third_entry.attributes.should == { "startedAt" => @midnight + idle_threshold + 4, "finishedAt" => nil, "duration" => 0 }
    third_entry.activity.should == none
  end

  it "when the user looks at a web page it assigns the last active project" do
    assume_autoparts_activity

    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    wait_until(@midnight + 2)
    active_uri_is("file://localhost/Users/John/Autoparts/main.rb")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("http://www.google.co.uk")
    @tracker.update

    wait_until(@midnight + 6)
    active_uri_is(nil)
    @tracker.update

    Entry.count.should == 3

    first_entry.activity.should == none
    second_entry.activity.should == @autoparts
    third_entry.activity.should == none

    second_entry.startedAt.should == @midnight + 2
    second_entry.finishedAt.should == @midnight + 6
    second_entry.duration.should == 4
  end

  it "stops the last entry when exiting" do
    wait_until(@midnight)
    active_uri_is(nil)
    create_tracker

    wait_until(@midnight + 2)
    active_uri_is(nil)
    @tracker.stop

    Entry.count.should == 1

    first_entry.finishedAt.should == @midnight + 2
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

def user_is_idle
  IdleDetector.stub!(:idle?, return: true)
end

def user_is_active
  IdleDetector.stub!(:idle?, return: false)
end

def wait_until(time)
  time_is(time)
end

def time_is(time)
  Time.stub!(:now, return: time)
end

def active_uri_is(uri)
  AppleScriptRunner.stub!(:run) do |_source|
    OpenStruct.new(stringValue: uri)
  end
end

def idle_threshold
  IdleDetector::IDLE_THRESHOLD
end

def idle
  Activity.idle
end

def none
  Activity.none
end

def assume_autoparts_activity
  @autoparts = Activity.create(name: "Autoparts", urlString: "file://localhost/Users/John/Autoparts")
end

def assume_careers_activity
  @careers = Activity.create(name: "Careers", urlString: "file://localhost/Users/John/Careers")
end

def create_tracker
  frontmost_application = OpenStruct.new(bundleIdentifier: "com.notlapsus", processIdentifier: "1234")
  workspace = OpenStruct.new(frontmostApplication: frontmost_application)
  @tracker = ActiveDocumentTracker.new(@app_delegate.cdq, workspace)
end
