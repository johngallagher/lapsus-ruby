class ActiveDocumentTracker
  def initialize(cdq, grabber, idle_detector, time_class)
    @grabber, @idle_detector = grabber, idle_detector
    @time_class = time_class
    @cdq = cdq
  end

  def update
    return if Project.count == 0

    active_url = @grabber.grab
    if active_url.start_with?(Project.first.urlString)
      @active_entry = Entry.create
      @active_entry.start(@time_class)
      @active_entry.project = Project.first
    elsif @active_entry
      @active_entry.finish(@time_class)
      @cdq.save
    end
  end
end


class FakeURIGrabber
  attr_accessor :uri

  def grab
    @uri
  end
end

class URIGrabber
  def grab
    bundle_identifier = NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
    source = %Q[
      tell application "System Events"
         value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundle_identifier}"))
      end tell 
    ]
    script = NSAppleScript.alloc.initWithSource(source)
    active_url = script.executeAndReturnError(nil)
    if active_url && active_url.stringValue
      active_url.stringValue
    else
      'missingfile://'
    end
  end
end

class FakeIdleDetector
  attr_accessor :idle

  def initialize
    @idle = false
  end

  def idle?
    @idle
  end
end

class IdleDetector
  def idle?
    false 
  end
end

class FakeDate
  attr_accessor :now
end

class AppDelegate
  include CDQ
  attr_reader :idle_detector, :uri_grabber, :time_class, :tracker

  def applicationDidFinishLaunching(_notification)
    if RUBYMOTION_ENV == 'test'
      #cdq.stores.new(in_memory: true)
      @idle_detector = FakeIdleDetector.new
      @uri_grabber = FakeURIGrabber.new
      @time_class = FakeDate.new
    else
      @idle_detector = IdleDetector.new
      @uri_grabber = URIGrabber.new
      @time_class = Time
    end 

    cdq.setup

    @tracker = ActiveDocumentTracker.new(cdq, @uri_grabber, @idle_detector, @time_class)

    if RUBYMOTION_ENV == 'test'
      @timer = nil
    else
      @timer = EM.add_periodic_timer 1.0 do
        @tracker.update
      end
    end
    true
  end
end
