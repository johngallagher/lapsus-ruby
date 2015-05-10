
describe URIGrabber do
  it "returns missing file if Lapsus is active" do
    assuming_active_application(bundle_identifier: NSBundle.mainBundle.bundleIdentifier)
    URIGrabber.new(@workspace).grab.should == URIGrabber::MISSING_FILE_URL
  end

  it "returns missing file if there was an error grabbing the window" do
    assuming_error_grabbing_active_uri
    assuming_active_application(bundle_identifier: "com.notlapsus")
    URIGrabber.new(@workspace).grab.should == URIGrabber::MISSING_FILE_URL
  end

  it "returns the active uri" do
    lapsus_main = "file://localhost/Users/Documents/Lapsus/main.rb"
    assuming_active_uri(lapsus_main)
    URIGrabber.new(@workspace).grab.should == NSURL.URLWithString(lapsus_main)
  end

  it "uses correct Applescript for Safari" do
    URIGrabber.new(@workspace).source_from_application("com.apple.Safari", "1234").should == %( tell application "Safari" to return URL of front document )
  end

  it "uses correct Applescript for Google Chrome" do
    URIGrabber.new(@workspace).source_from_application("com.google.Chrome", "1234").should == %( tell application "Google Chrome" to return URL of active tab of front window )
  end

  it "uses correct Applescript for other applications" do
    URIGrabber.new(@workspace).source_from_application("com.sublimetext2", "1234").should == %[ tell application "System Events" to return value of attribute "AXDocument" of (front window of (first process whose unix id is 1234)) ]
  end
end

def assuming_active_uri(uri)
  AppleScriptRunner.stub!(:run){ |_source| OpenStruct.new(stringValue: uri) }
end

def assuming_error_grabbing_active_uri
  AppleScriptRunner.stub!(:run){ |_source| nil }
end

def sublime_text
  OpenStruct.new(bundleIdentifier: "com.sublimetext2")
end

def safari
  OpenStruct.new(bundleIdentifier: "com.apple.Safari")
end

def google_chrome
  OpenStruct.new(bundleIdentifier: "com.google.Chrome")
end

def assuming_active_application(opts)
  frontmost_application = OpenStruct.new(bundleIdentifier: opts.fetch(:bundle_identifier),
                                         processIdentifier: opts.fetch(:process_identifier, "1234"))
  @workspace = OpenStruct.new(frontmostApplication: frontmost_application)
end
