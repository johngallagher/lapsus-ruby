require "spec_helper"

class FakeIdleDetector
  attr_writer :idle

  def initialize
    @idle = false
  end

  def idle?
    @idle
  end
end

describe ActiveDocumentTracker do
  before do
    @shared_app = NSApplication.sharedApplication
    @app_delegate = @shared_app.delegate

    @midnight = Time.new(2014, 6, 2, 0, 0, 0)
    @idle_detector = FakeIdleDetector.new
    active_uri_is("missingfile://")
  end

  after do
    @app_delegate.cdq.reset!
  end

  it "records time for two activities" do
    assume_autoparts_activity
    assume_careers_activity

    wait_until(@midnight)
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)

    wait_until(@midnight + 2)
    active_uri_is("file://Users/John/Autoparts/main.rb")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("file://Users/John/Careers/main.rb")
    @tracker.update

    wait_until(@midnight + 6)
    active_uri_is("missingfile://")
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
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)

    wait_until(@midnight + 2)
    active_uri_is("file://Users/John/Autoparts/main.rb")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("missingfile://")
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
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)

    wait_until(@midnight + 2)
    active_uri_is("missingfile://")
    @tracker.update

    wait_until(@midnight + 4)
    active_uri_is("file://Users/John/Autoparts/main.rb")
    @tracker.update

    Entry.count.should == 2

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 4, "duration" => 4 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 4, "finishedAt" => nil, "duration" => 0 }
    second_entry.activity.should == @autoparts
  end

  it "with no projects it only tracks none" do
    wait_until(@midnight)
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)
    @tracker.update

    Entry.count.should == 1
    first_entry.activity.should == none
  end

  # it "continues recording when user is idle for less than the threshold then becomes active" do

  # end

  it "stops recording when the user has been idle for more than the threshold" do
    assume_autoparts_activity

    wait_until(@midnight)
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)

    user_is_idle
    wait_until(@midnight + 2)
    @tracker.update

    user_is_idle
    wait_until(@midnight + idle_threshold + 2)
    @tracker.update

    Entry.count.should == 2

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => nil, "duration" => 0 }
    second_entry.activity.should == idle
  end

  it "continues recording when the user wakes up" do
    assume_autoparts_activity

    wait_until(@midnight)
    @tracker = ActiveDocumentTracker.new(@app_delegate.cdq)

    user_is_idle
    wait_until(@midnight + 2)
    @tracker.update

    user_is_idle
    wait_until(@midnight + idle_threshold + 2)
    @tracker.update

    user_is_active
    wait_until(@midnight + idle_threshold + 10)
    @tracker.update

    Entry.count.should == 3

    first_entry.attributes.should == { "startedAt" => @midnight, "finishedAt" => @midnight + 2, "duration" => 2 }
    first_entry.activity.should == none

    second_entry.attributes.should == { "startedAt" => @midnight + 2, "finishedAt" => @midnight + idle_threshold + 10, "duration" => idle_threshold + 8 }
    second_entry.activity.should == idle

    third_entry.attributes.should == { "startedAt" => @midnight + idle_threshold + 10, "finishedAt" => nil, "duration" => 0 }
    third_entry.activity.should == none
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

def user_is_idle
  IdleDetector.stub!(:idle?, return: true)
end

def user_is_active
  IdleDetector.stub!(:idle?, return: true)
end

def wait_until(time)
  time_is(time)
end

def time_is(time)
  Time.stub!(:now, return: time)
end

def active_uri_is(uri)
  URIGrabber.stub!(:grab, return: uri)
end

def idle_threshold
  User::IDLE_TIME
end

def idle
  Activity.find_idle
end

def none
  Activity.find_none
end

def assume_autoparts_activity
  @autoparts = Activity.create(name: "Autoparts", urlString: "file://Users/John/Autoparts")
end

def assume_careers_activity
  @careers = Activity.create(name: "Careers", urlString: "file://Users/John/Careers")
end
